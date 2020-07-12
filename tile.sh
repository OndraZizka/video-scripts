#!/bin/bash

## Tiles several videos to one.
## Written as per https://trac.ffmpeg.org/wiki/Create%20a%20mosaic%20out%20of%20several%20input%20videos
## Alternatively could be done using https://ffmpeg.org/ffmpeg-filters.html#xstack
## See https://stackoverflow.com/questions/11552565/vertically-or-horizontally-stack-several-videos-using-ffmpeg/33764934#33764934

## Either processes the files in 

TILE_WID=480; TILE_HEI=270
##  My UWQHD = 3440 x 1440
TILE_WID=512; TILE_HEI=288  ## Fits 6 x 5
TILE_WID=416; TILE_HEI=234  ## 16:9 * 26; fits 8 x 6
##  UltraHD = 3840 x 2160
TILE_WID=480; TILE_HEI=270  ## fits 8 x 8


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
  ## We will search for the inputs and pick randomly. This part is tailored to me, should be externalized.
  COLS=${2:-6}
  ROWS=${3:-5}
  INPUT_COUNT=$((COLS * ROWS))
  INPUTS=`find $INPUTS_DIR \( -iname '*.mp4' -o -iname '*.avi' -o -iname '*.mkv' -o -iname '*.webm' -o -iname '*.mov' \) \
            ! -name '*-clip*' -a ! -name '*-crop*' -a ! -name '*-mute*' -a ! -iname '*zivot*' \
            -a ! -name '*-0.*' -a ! -name '*-0-*' \
            -a ! -name '*-1.*' -a ! -name '*-1-*' \
            -a ! -name '*-2.*' -a ! -name '*-2-*' \
            -a -size +1500M -a -size -3000M \
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
    XSTACK_SOURCES="$XSTACK_SOURCES[$TILE_ID]"
    XSTACK_LAYOUT="$XSTACK_LAYOUT|${X}_${Y}"
    ((I++))
    if [ $I != $INPUT_COUNT ] ; then OVERLAYS="$OVERLAYS [lay$I]; $NL"; fi
    ((X += TILE_WID))
  done
  ((Y += TILE_HEI)) 
done

SIZE=$((TILE_WID*COLS))x$((TILE_HEI*ROWS));
XSTACK_LAYOUT="`echo $XSTACK_LAYOUT | sed 's#^|##'`";

echo "ffmpeg \\
$INPUTS
    -filter_complex \"
$STREAMS\
    ${XSTACK_SOURCES}xstack=inputs=$INPUT_COUNT:layout=$XSTACK_LAYOUT\
    \" \
     -c:v libx264 ./tiled.mp4
  ";

## $OVERLAYS was replaced with the xstack line.
  
<<EOF
##  xstack way:   See https://ffmpeg.org/ffmpeg-filters.html#xstack
ffmpeg -i input0 -i input1 -i input2 -i input3 -filter_complex
"[0]drawtext=text='vid0':fontsize=20:x=(w-text_w)/2:y=(h-text_h)/2[v0];
 [1]drawtext=text='vid1':fontsize=20:x=(w-text_w)/2:y=(h-text_h)/2[v1];
 [2]drawtext=text='vid2':fontsize=20:x=(w-text_w)/2:y=(h-text_h)/2[v2];
 [3]drawtext=text='vid3':fontsize=20:x=(w-text_w)/2:y=(h-text_h)/2[v3];
 [v0][v1][v2][v3]xstack=inputs=4:layout=0_0|w0_0|0_h0|w0_h0[v]"
-map "[v]" output
EOF
