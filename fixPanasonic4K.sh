#!/bin/bash

INPUT="$1"

BASE_NAME=`basename "$INPUT"`
BASE_NAME="${BASE_NAME%.*}"
SUFFIX=${INPUT##*.}

NEW_NAME="$BASE_NAME"~fixPana.$SUFFIX
NEW_NAME="${4:-$NEW_NAME}"

FILTER='
[in] split [a][b]; 
[a] crop=1920:540:0:0 [ac]; 
[b] crop=1920:540:1920:0 [bc]; 
[ac][bc] vstack [stack];
[stack] il=luma_mode=interleave:chroma_mode=interleave'  

if [ "$2" != "" ] ; then
  ffplay -i "$INPUT" -vf "$FILTER"
else
  set -x
  ffmpeg -i "$INPUT" -filter:v "$FILTER" $QUALITY_GOOD_H265 -c:a copy "$NEW_NAME" \
  && touch "$NEW_NAME" -r "$INPUT"
  set +x
fi

