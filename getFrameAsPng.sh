

## Just an example...
for i in *.MP4; do 
    for s in 1 20 22 23; do 
        mkdir -p s$s
        ffmpeg -ss $s -i "$i" -vframes 1 "s$s/$i-s$s.png"
    done
done

## PNG is lossless.
