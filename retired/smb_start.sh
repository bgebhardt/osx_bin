#!/bin/sh

# a very simple  script to start smbd and nmbd
# NOTE: will prompt for administrator password to start them as root.
#sudo /usr/sbin/smbd -D
#sudo /usr/sbin/nmbd -D

smbd_pid=`ps -ax | grep -i smbd | grep -i -v "grep.-i.smbd" | cut -c1-5`
nmbd_pid=`ps -ax | grep -i nmbd | grep -i -v "grep.-i.nmbd" | cut -c1-5`

# functions for each action

smb_start()
{
    echo -n "Starting up samba..."
    sudo /usr/sbin/smbd -D
    sudo /usr/sbin/nmbd -D
    echo "done"
}

smb_stop()
{
   if [ $nmbd_pid ]
    then
	echo "Shutting down samba..."
    
	echo "smbd PID is $smbd_pid; nmbd PID is $nmbd_pid."

	sudo kill $smbd_pid
	sudo kill $nmbd_pid

	echo "done"
    else
	echo "samba is not running."
    fi
}

smb_status()
{
   if [ $nmbd_pid ]
    then
	echo "samba is running."
	echo "smbd PID is $smbd_pid; nmbd PID is $nmbd_pid."
    else
	echo "samba is not running."
    fi
}

smb_help()
{
   echo "usage: $0 {start|stop|status}"
   echo " start starts up samba."
   echo " stop stops samba."
   echo " restart stops and then starts samba."
   echo " status returns whether or not samba is running."
   exit 2
}

case $1 in
    start) smb_start ;;
    stop) smb_stop ;;
    status) smb_status ;;
    restart) smb_stop; smb_start ;;
    *) smb_help ;;
esac

