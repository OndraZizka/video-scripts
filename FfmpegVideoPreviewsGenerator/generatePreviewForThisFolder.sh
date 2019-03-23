#!/bin/bash
SCRIPT_DIR=$(dirname $(realpath $0))

find /media/ondra/SeaRed/_VT/ -iname '*.mp4' -o -iname '*.avi' -o -iname '*.mkv' -o -iname '*.webm' -o -iname '*.mov' | sort | xargs -rl -I {}  "$SCRIPT_DIR/videoPreviewGenerator.sh" "{}"
