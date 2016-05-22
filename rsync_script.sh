#!/bin/sh 

# run from cmd line with:
# rsync_script.sh >| rsync_log.`date +%a` & 

# /usr/bin/rsync -avnEze ssh --exclude-from="/Users/bryan/bin/rsync_exclude.txt" /Users/bryan bryan@192.168.0.5:/Users/bryan
# E = file attributes (labels, etc)
# a = archive
# n = dry run
# e = use ssh
# v = verbose
# --progress = progress bar
# -u, --update                update only (don't overwrite newer files) 
# z = compress
# --delete = delete files in dest that aren't in source

echo "Starting Daily rsync backup on `date`"
DESTHOST="bryan@192.168.0.5"
DESTDIR="/Users/bryan/Backup/"
DEST=$DESTHOST:$DESTDIR

SOURCE="/Users/bryan/"
EXCLUDES="/Users/bryan/bin/rsync_exclude.txt"
echo "DEST=$DEST"
echo "SOURCE=$SOURCE"
echo "Using exclude file: $EXCLUDES"

# First check for existance of DESTDIR
# this doesn't work
#ssh $DESTHOST 'test -d $DESTDIR'
#if [ $? != 0 ]; then
#	echo " ==> Error: up destination $DEST was not present"
#fi

# don't need this as we use ssh
#if [ -d $DEST ]; then
#for FSYS in /Users
#do
        time /usr/bin/rsync -avEze ssh --delete --exclude-from=$EXCLUDES $SOURCE $DEST
        if [ $? != 0 ]; then
                echo " ==> Error during rsync of $SOURCE"
        else
                echo "rsync of $SOURCE OK on `date`"
        fi
#done

#else
#        echo "==> Backup destination $DEST was not present"
#fi

echo "Finished Daily rsync backup at `date`"

# Help and Tips

#Trailing Slashes Do Matter...Sometimes
# from http://www.mikerubel.org/computers/rsync_snapshots/#Rsync
#This isn't really an article about rsync, but I would like to take a momentary 
#detour to clarify one potentially confusing detail about its use. You may be 
#accustomed to commands that don't care about trailing slashes. For example, if a 
#and b are two directories, then cp -a a b is equivalent to cp -a a/ b/. However, 
#rsync does care about the trailing slash, but only on the source argument. For 
#example, let a and b be two directories, with the file foo initially inside 
#directory a. Then this command:

#rsync -a a b
#produces b/a/foo, whereas this command:

#rsync -a a/ b
#produces b/foo. The presence or absence of a trailing slash on the destination 
#argument (b, in this case) has no effect.

#Using the --delete flag
#If a file was originally in both source/ and destination/ (from an earlier rsync, 
#for example), and you delete it from source/, you probably want it to be deleted 
#from destination/ on the next rsync. However, the default behavior is to leave 
#the copy at destination/ in place. Assuming you want rsync to delete any file 
#from destination/ that is not in source/, you'll need to use the --delete flag:

#rsync -a --delete source/ destination/
