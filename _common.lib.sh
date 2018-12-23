#!/bin/bash

## For the details, see https://trac.ffmpeg.org/wiki/Encode/H.264

BEST_CODEC="-c:v libx264  -crf 17"         # -qp 0 is looseless.
BEST_PRESET="-preset slow -tune film"      # -b:v 555k | 1M etc.
BEST_PROFILE="-profile:v high -level 4.2"  ## Use the newest H264 features for encoding.

BEST_VIDEO="$BEST_CODEC $BEST_PRESET $BEST_PROFILE"

COMPAT_MODE="-pix_fmt yuv420p"

RED='\033[0;31m'
BLUE='\033[1;34m'
NOCOLOR='\033[0m'

###
###  Compute difference between two dates
###
function countTimeDiff2() {
    set -x
    StartDate=$(date -u -d "$1" +"%s")
    FinalDate=$(date -u -d "$2" +"%s")
    date -u -d "0 $FinalDate sec - $StartDate sec" +"%H:%M:%S"
    set +x
}

function countTimeDiff() {
    timeA=$1 # 09:59:35
    timeB=$2 # 17:32:55

    # feeding variables by using read and splitting with IFS
    IFS=: read ah am as <<< "$timeA"
    IFS=: read bh bm bs <<< "$timeB"

    # Convert hours to minutes.
    # The 10# is there to avoid errors with leading zeros
    # by telling bash that we use base 10
    secondsA=$((10#$ah*60*60 + 10#$am*60 + 10#$as))
    secondsB=$((10#$bh*60*60 + 10#$bm*60 + 10#$bs))
    DIFF_SEC=$((secondsB - secondsA))
    echo "The difference is $DIFF_SEC seconds.";

    SEC=$(($DIFF_SEC%60))
    MIN=$((($DIFF_SEC-$SEC)%3600/60))
    HRS=$((($DIFF_SEC-$MIN*60)/3600))
    TIME_DIFF="$HRS:$MIN:$SEC";
    echo $TIME_DIFF;
}

