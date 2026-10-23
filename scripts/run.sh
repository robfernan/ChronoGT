#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DEVICE="${1:-venu3}"


export LD_LIBRARY_PATH="/home/rf80678/.local/lib:${LD_LIBRARY_PATH:-}"
export DISPLAY="${DISPLAY:-:0}"
export LC_ALL=C.UTF-8

# 1. Start simulator if not already running
if ! pgrep -f "$SDK_BIN/simulator" >/dev/null; then
    echo "Starting Garmin CIQ Simulator..."
    nohup "$SDK_BIN/simulator" >/tmp/ciq_sim.log 2>&1 &
    sleep 3
fi

# 2. Compile watch face
echo "Compiling ChronoGT for $DEVICE..."
"$SDK_BIN/monkeyc" \
    -d "$DEVICE" \
    -f "$PROJECT_DIR/monkey.jungle" \
    -o "$PROJECT_DIR/bin/ChronoGT-$DEVICE.prg" \
    -y ~/.Garmin/ConnectIQ/developer_key.der \
    -w

# 3. Push executable into the running simulator
pkill -f "MonkeyDoDeux" 2>/dev/null || true
echo "Loading ChronoGT-$DEVICE.prg into simulator..."
setsid "$SDK_BIN/monkeydo" "$PROJECT_DIR/bin/ChronoGT-$DEVICE.prg" "$DEVICE" >/tmp/monkeydo.log 2>&1 </dev/null &
sleep 3
echo "Loaded! Check the CIQ Simulator window."
