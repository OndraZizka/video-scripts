#!/bin/bash

if [ "" == "$1" ] ; then echo "Usage: $0 <videoFile>"; echo "Output format: h:mm:ss.ss"; exit 1; fi

#exiftool "$1" | grep -E '^Duration +: .+' | cut -d':' -f2-
exiftool -T -Duration "$1"

## Alternatives:
# mediainfo --Inform="Video;%Duration%"  [inputfile]
# ffprobe video.mp4 2>&1 | grep -E '^ +Duration' | cut -d':' -f2- | cut -d, -f1
# avprobe file.mp4 -show_format_entry duration
# avprobe file.mp4 -show_entries format=duration
