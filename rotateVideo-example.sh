

##  1 = Clockwise
##  2 = Counterclockwise
ffmpeg -i in.mp4 -vf "transpose=2" -acodec copy  out.mp4

##  180 deg.
ffmpeg -i in.mp4 -vf "vflip,hflip" -acodec copy  out.mp4

ffmpeg -i input -vcodec libx264 -preset medium -crf 24 -threads 0 -vf transpose=2 -acodec copy output.mkv


## The following would clip the first 30 seconds, and then clip everything that is 10 seconds after that:
ffmpeg -i input.wmv -ss 00:00:30.0 -c copy -t 00:00:10.0 output.wmv
ffmpeg -i input.wmv -ss 30 -c copy -t 10 output.wmv

## Avoid beginning gap:
## Example: If you want to make a 1-minute clip, from 9min0sec to 10min 0sec in Video.mp4, you could do it both quickly and accurately using:
ffmpeg -ss 00:08:00 -i Video.mp4 -ss 00:01:00 -t 00:01:00 -c copy VideoClip.mp4


## FFMpeg command examples:
http://randombio.com/linuxsetup141.html