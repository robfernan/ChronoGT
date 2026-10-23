#!/usr/bin/env bash
set -euo pipefail

export DISPLAY=:0
PROJECT_DIR="/home/rf80678/Documents/Projects/Garmin/ChronoGT"
cd "$PROJECT_DIR"

WID=$(xwininfo -root -tree | grep 'CIQ Simulator - Venu' | awk '{print $1}' | head -n 1 || true)
if [ -z "$WID" ]; then
    echo "Simulator window not found! Launching..."
    ./run.sh venu3
    sleep 4
    WID=$(xwininfo -root -tree | grep 'CIQ Simulator - Venu' | awk '{print $1}' | head -n 1)
fi

echo "Recording full 60-second lap at 10 FPS directly from window $WID..."
mkdir -p frames_60s
rm -f frames_60s/*.png

for i in $(seq 1 600); do
    filename=$(printf "frames_60s/frame_%04d.png" "$i")
    import -window "$WID" "$filename" 2>/dev/null || true
    sleep 0.1
done

echo "Frames captured: $(ls frames_60s/ | wc -l)"

echo "Encoding 1080x1920 YouTube Short..."
ffmpeg -y -framerate 10 -i frames_60s/frame_%04d.png \
  -vf "crop=440:550:100:90,scale=1080:1350:flags=lanczos,pad=1080:1920:(ow-iw)/2:(oh-ih)/2:black" \
  -c:v libx264 -pix_fmt yuv420p -r 30 -movflags +faststart \
  youtube_short_60s.mp4

rm -rf frames_60s
echo "SUCCESS: Created youtube_short_60s.mp4!"
ls -lh youtube_short_60s.mp4
