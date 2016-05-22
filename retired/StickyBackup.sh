#!/bin/sh

# Shell script to automatically back up 
# Apple's Stickies database files

# puts sticky DB back ups in ~/Documents/StickyBackup/

backupDir=~/Documents/StickiesBackup/
backupFileName=StickiesDatabase
stickyLoc=~/Library/StickiesDatabase

# check if we're running 10.2
#  stickies DB is an invisible file in 10.1 and before.
# TODO

# first make the backup director if necessary
if [ ! -d $backupDir ] ; then
    mkdir $backupDir
fi

# Rotate the back ups.  There are 7 of them.
cd $backupDir

if [ -f "${backupFileName}.6" ]; then mv -f "${backupFileName}.6" "${backupFileName}.7"; fi
if [ -f "${backupFileName}.5" ]; then mv -f "${backupFileName}.5" "${backupFileName}.6"; fi
if [ -f "${backupFileName}.4" ]; then mv -f "${backupFileName}.4" "${backupFileName}.5"; fi
if [ -f "${backupFileName}.3" ]; then mv -f "${backupFileName}.3" "${backupFileName}.4"; fi
if [ -f "${backupFileName}.2" ]; then mv -f "${backupFileName}.2" "${backupFileName}.3"; fi
if [ -f "${backupFileName}.1" ]; then mv -f "${backupFileName}.1" "${backupFileName}.2"; fi

# Now back up the Stickes Database
if [ -f "${stickyLoc}" ]; then cp -f "${stickyLoc}" "${backupFileName}.1"; fi
