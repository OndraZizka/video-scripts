#!/bin/bash
SCRIPT_DIR=$(dirname $(realpath $0))

FILMS_DIR=${1:-/media/ondra/SeaRed/._VT/}

find "$FILMS_DIR" -iname '*.mp4' -o -iname '*.avi' -o -iname '*.mkv' -o -iname '*.webm' -o -iname '*.mov' | sort | xargs -rl -I {}  "$SCRIPT_DIR/videoPreviewGenerator.sh" "{}"

