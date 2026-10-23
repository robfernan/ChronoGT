#!/usr/bin/env bash
# record.sh — Automated recorder for ChronoGT in the Garmin CIQ Simulator
# Generates both a looping preview.gif and a 9:16 vertical MP4 for YouTube Shorts.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DURATION="${1:-15}"  # default 15 seconds
DEVICE="${2:-venu3}"

TMP_DIR="/tmp/chronogt_rec_$$"

mkdir -p "$TMP_DIR"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Ensuring ChronoGT is running on $DEVICE..."
"$PROJECT_DIR/run.sh" "$DEVICE"
sleep 4

WIN=""
for id in $(xprop -root _NET_CLIENT_LIST 2>/dev/null | grep -oE '0x[0-9a-f]+'); do
  if xprop -id "$id" WM_NAME 2>/dev/null | grep -qi 'CIQ Simulator'; then
    WIN="$id"
  fi
done

if [ -z "$WIN" ]; then
  echo "Error: CIQ Simulator window not found!" >&2
  exit 1
fi

echo "Simulator window: $WIN"
echo "Recording $DURATION seconds at 10 fps..."

FPS=10
TOTAL_FRAMES=$(( DURATION * FPS ))
SLEEP_INTERVAL="0.1"

for i in $(seq -w 1 "$TOTAL_FRAMES"); do
  import -window "$WIN" -crop 636x662+0+0 +repage "$TMP_DIR/frame_$i.png" 2>/dev/null || true
  sleep "$SLEEP_INTERVAL"
done

FRAME_COUNT=$(find "$TMP_DIR" -name 'frame_*.png' | wc -l)
echo "Captured $FRAME_COUNT frames."

if [ "$FRAME_COUNT" -lt 5 ]; then
  echo "Error: Not enough frames captured (is the simulator window minimized?)" >&2
  exit 1
fi

# 1. Generate Looping GIF for GitHub README / DeviantArt
echo "Generating preview.gif..."
ffmpeg -y -framerate "$FPS" -i "$TMP_DIR/frame_%0${#TOTAL_FRAMES}d.png" \
  -vf "fps=10,scale=480:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
  "$PROJECT_DIR/preview.gif"

# 2. Generate 1080x1920 (9:16) Vertical Video for YouTube Shorts / TikTok / Reels
echo "Generating youtube_short.mp4..."
ffmpeg -y -framerate "$FPS" -i "$TMP_DIR/frame_%0${#TOTAL_FRAMES}d.png" \
  -vf "scale=800:832:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2:color=black,format=yuv420p" \
  -c:v libx264 -preset fast -crf 20 \
  "$PROJECT_DIR/youtube_short.mp4"

echo "Done!"
ls -lh "$PROJECT_DIR/preview.gif" "$PROJECT_DIR/youtube_short.mp4"
