#!/bin/bash

## Tiles several videos to one.
## Written as per https://trac.ffmpeg.org/wiki/Create%20a%20mosaic%20out%20of%20several%20input%20videos
## Alternatively could be done using https://ffmpeg.org/ffmpeg-filters.html#xstack
## See https://stackoverflow.com/questions/11552565/vertically-or-horizontally-stack-several-videos-using-ffmpeg/33764934#33764934

## Either processes the files in 

TILE_WID=480
TILE_HEI=270


if [ ! -d "$1" -a '-' != "$1" ] ; then 
    echo "Usage: $0 <inputDir|-> [<cols> [<rows>]]"; exit 1; 
fi

if [ '-' == "$1" ] ; then
  ## A list of inputs is on standard input.
  INPUT_COUNT=0
  while read -r LINE; do
    INPUTS=" -i $LINE";
    ((INPUT_COUNT += 1))
  done;
  
  SQRT=$(echo "scale=2;sqrt($INPUT_COUNT)" | bc)
  SQRT=$(($SQRT%1 ? $SQRT + 1 : SQRT))
  COLS=$SQRT
  ROWS=$SQRT
else
  INPUTS_DIR="$1"
  ## We will search for the inputs and pick randomly.
  COLS=${2:-2}
  ROWS=${3:-2}
  INPUT_COUNT=$((COLS * ROWS))
  INPUTS=`find $INPUTS_DIR \( -iname '*.mp4' -o -iname '*.avi' -o -iname '*.mkv' -o -iname '*.webm' -o -iname '*.mov' \) \
            ! -name '*-clip*' -a ! -name '*-crop*' -a ! -name '*-mute*' -a ! -iname '*zivot*' -a -size +200M \
            | shuf | head -n $INPUT_COUNT | xargs  -r -l -I {}  echo "     -i '{}' \\\\"`
fi
## Now we should have: INPUTS, COLS, ROWS, INPUT_COUNT.

I=0
Y=0
OVERLAYS=""
STREAMS=""
NL="
";
for ROW in `seq 1 1 $ROWS` ; do
  X=0
  for COL in `seq 1 1 $COLS` ; do
    TILE_ID="TILE_${ROW}_${COL}"
    STREAMS="$STREAMS          [$I:v] setpts=PTS-STARTPTS, scale=${TILE_WID}x${TILE_HEI} [$TILE_ID]; $NL"
    OVERLAYS="$OVERLAYS          [lay$I][$TILE_ID] overlay=shortest=1:x=$X:y=$Y"
    ((I++))
    if [ $I != $INPUT_COUNT ] ; then OVERLAYS="$OVERLAYS [lay$I]; $NL"; fi
    ((X += TILE_WID))
  done
  ((Y += TILE_HEI)) 
done

SIZE=$((TILE_WID*COLS))x$((TILE_HEI*ROWS));

echo "ffmpeg \\
$INPUTS
    -filter_complex \"nullsrc=size=$SIZE [lay0];
$STREAMS\
$OVERLAYS\
     \" \
     -c:v libx264 ./tiled.mp4
  ";

