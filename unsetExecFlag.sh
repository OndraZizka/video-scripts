
## Removes the exec flag from all files in given dir, but not from the directories.
## See https://unix.stackexchange.com/questions/296967/how-to-recursively-remove-execute-permissions-from-files-without-touching-folder

if [ ! -d "$1" ] ; then echo "Usage: $0 <dirWithFiles>"; exit; fi

chmod -R -x+X "$1"/*

