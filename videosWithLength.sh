



find -name '*.mp4' -exec echo -n {}" | " \; -exec ffprobe -show_entries format=duration -of default=noprint_wrappers=1:nokey=0 -v quiet -sexagesimal {} \; > videos+durations.csv 
cat videos+durations.csv | awk '{ print $2 "|" $1 }' FS='|' | sort
