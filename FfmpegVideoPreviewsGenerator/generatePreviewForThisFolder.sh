#!/bin/bash
SCRIPT_DIR=$(dirname $(realpath $0))

#FILMS_DIR=${1:-/media/ondra/SeaRed/._VT/}

FILMS_DIR=${1}

if [ "" == "$FILMS_DIR" ] ; then echo "Usage: $0 <dirWithMovies> [tilesX=6] [tilesY=6] [height=240]"; exit 1; fi

TILES_X="${2:-12}"
TILES_Y="${3:-12}"
TILE_HEIGHT="${4:-120}"

find "$FILMS_DIR" -iname '*.mp4' -o -iname '*.avi' -o -iname '*.mkv' -o -iname '*.webm' -o -iname '*.mov' | sort | \
  xargs -rl -I {}  "$SCRIPT_DIR/videoPreviewGenerator.sh" "{}" "$TILE_HEIGHT" "$TILES_X" "$TILES_Y"

