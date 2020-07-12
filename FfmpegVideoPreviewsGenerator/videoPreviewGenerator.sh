#!/bin/bash
SCRIPT_DIR=$(dirname $(realpath $0))

# Bash script that generates film strip video preview using ffmpeg
# You can see live demo: http://jsfiddle.net/r6wz0nz6/2/
# Tutorial on Binpress.com: http://www.binpress.com/tutorial/generating-nice-movie-previews-with-ffmpeg/138

if [ -z "$1" ]; then
    #echo "usage: ./movie_preview.sh VIDEO [HEIGHT=120] [COLS=100] [ROWS=1] [OUTPUT]"
    echo "usage: $0 <videoFile> <height:240> <cols:6> <rosw:6> <output:~_preview.jpg>"
    exit
fi

MOVIE="$1"
# get video name without the path and extension
MOVIE_NAME="`basename "$MOVIE"`"
OUT_DIR="`pwd`"
if [ "$OUT" == "here" ] ; then
    OUT_DIR="`pwd`"
else
    OUT_DIR="`dirname "$MOVIE"`"
fi


HEIGHT=${2:-240}
COLS=${3:-6}
ROWS=${4:-6}
OUT_FILENAME="$5"


if [ -z "$HEIGHT" ]; then
    HEIGHT=240
fi
if [ -z "$COLS" ]; then
    COLS=6
fi
if [ -z "$ROWS" ]; then
    ROWS=6
fi
if [ -z "$OUT_FILENAME" ]; then
    #OUT_FILENAME="`echo "${MOVIE_NAME%.*}_preview.jpg"`"
    OUT_FILENAME="`echo "${MOVIE_NAME%.*}_pre${COLS}x${ROWS}.png"`"
fi

OUT_FILEPATH="`echo "$OUT_DIR/$OUT_FILENAME"`"
if [ -f "$OUT_FILEPATH" ] ; then echo "Already exists, skipping: $OUT_FILEPATH"; exit; fi

TOTAL_IMAGES=`echo "$COLS*$ROWS" | bc`


# get total number of frames in the video
echo "$0: Probing file: $MOVIE"
# ffprobe is fast but not 100% reliable. It might not detect number of frames correctly!
NB_FRAMES=`ffprobe -show_streams "$MOVIE" 2> /dev/null | grep nb_frames | head -n1 | sed 's/.*=//'`
# `-show-streams` Show all streams found in the video. Each video has usualy two streams (video and audio).
# `head -n1` We care only about the video stream which comes first.
# `sed 's/.*=//'` Grab everything after `=`.

if [ "$NB_FRAMES" = "N/A" ]; then
    # as a fallback we'll use ffmpeg. This command basically copies this video to /dev/null and it counts
    # frames in the process. It's slower (few seconds usually) than ffprobe but works everytime.
    NB_FRAMES=`ffmpeg -nostats -i "$MOVIE" -vcodec copy -f rawvideo -y /dev/null 2>&1 | grep frame | awk '{split($0,a,"fps")}END{print a[1]}' | sed 's/.*= *//'`
    # I know, that `awk` and `sed` parts look crazy but it has to be like this because ffmpeg can
    # `-nostats` By default, `ffmpeg` prints progress information but that would be immediately caught by `grep`
    #     because it would contain word `frame` and therefore output of this entire command would be totally
    #      random. `-nostats` forces `ffmpeg` to print just the final result.
    # `-i "$MOVIE"` Input file
    # `-vcodec copy -f rawvideo` We don't want to do any reformating. Force `ffmpeg` to read and write the video as is.
    # `-y /dev/null` Dump read video data. We just want it to count frames we don't care about the data.
    # `awk ...` The line we're interested in has format might look like `frame= 42` or `frame=325`. Because of that
    #     extra space we can't just use `awk` to print the first column and we have to cut everything from the
    #     beggining of the line to the term `fps` (eg. `frame= 152`).
    # `sed ...` Grab everything after `=` and ignore any spaces
fi

# calculate offset between two screenshots, drop the floating point part
NTH_FRAME=`echo "$NB_FRAMES/$TOTAL_IMAGES" | bc`
echo "$0: Will capture every ${NTH_FRAME}th frame out of $NB_FRAMES frames."

DURATION=`ffprobe -v error -select_streams v:0 -show_entries stream=duration -of default=noprint_wrappers=1:nokey=1 "$MOVIE"`
DURATION=`echo "$DURATION - .5" | bc`  #${DURATION%%.}
NTH_SECOND=`echo "scale=3; $DURATION/$TOTAL_IMAGES" | bc`
echo "$0: Will capture every ${NTH_SECOND}th second out of $DURATION seconds."


# make sure output dir exists
mkdir -p "$OUT_DIR"



rm -f /tmp/videoPreviewGenerator/*
mkdir -p /tmp/videoPreviewGenerator/
#TOTAL_IMAGES=0
for i in `seq -f '%03.f' 1 $TOTAL_IMAGES`; do
#for i in `seq -f '%03f' 1 $NTH_SECOND $DURATION`; do
  #echo "scale=3; $i * $NTH_SECOND"
  offset=`echo "scale=3; $i * $NTH_SECOND" | bc`
  echo "  Tile $i -> offset $offset"
  ffmpeg -loglevel panic -accurate_seek -ss "$offset" -i "$MOVIE"  -frames:v 1 /tmp/videoPreviewGenerator/frame_$i.bmp
done
##  TODO: Figure out how to see to the frame, or, compute times instead of frames: Length / NB_FRAMES.
##  See `-ss 25+` - 25th second. And http://ffmpeg.org/ffmpeg-utils.html#time-duration-syntax
## Then we need to make the tile.
#ffmpeg -i /tmp/videoPreviewGenerator/frame_%03d.bmp -y -frames 1 -q:v 1  -vf "scale=-1:120,tile=${COLS}x${ROWS}" "$OUT_FILEPATH"
ffmpeg -i /tmp/videoPreviewGenerator/frame_%03d.bmp -frames 1 -q:v 1 -filter_complex "scale=-1:$HEIGHT,tile=${COLS}x${ROWS}" "$OUT_FILEPATH"
#montage *.jpg -mode Concatenate -tile 6x5 montage.jpg
exit 0


## Original way
## The approach through filters is quite slow, esp. for very long videos. The above should be around 20x faster.

FFMPEG_CMD="ffmpeg -loglevel panic -i \"$MOVIE\" -y -frames 1 -q:v 1 -vf \"select=not(mod(n\,$NTH_FRAME)),scale=-1:${HEIGHT},tile=${COLS}x${ROWS}\" \"$OUT_FILEPATH\""
# `-loglevel panic`    We don’t want to see any output. You can remove this option if you’re having any problem to see what went wrong
# `-i "$MOVIE"`        Input file
# `-y`                 Override any existing output file
# `-frames 1`          Tell `ffmpeg` that output from this command is just a single image (one frame).
# `-q:v 3`             Output quality where `0` is the best.
# `-vf \"select=`      That's where all the magic happens. Selector function for [video filter](https://trac.ffmpeg.org/wiki/FilteringGuide).
# # `not(mod(n\,58))`  Select one frame every `58` frames [see the documentation](https://www.ffmpeg.org/ffmpeg-filters.html#Examples-34).
# # `scale=-1:120`     Resize to fit `120px` height, width is adjusted automatically to keep correct aspect ration.
# # `tile=${COLS}x${ROWS}`   Layout captured frames into this grid


# print enire command for debugging purposes
echo "Will run FFmpeg:\n$FFMPEG_CMD"
echo "`date +%R` $OUT_FILEPATH"
eval $FFMPEG_CMD
echo
