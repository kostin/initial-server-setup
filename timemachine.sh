#!/bin/sh

DATE=`date "+%Y-%m-%d_%H-%M-%S"`
USER="$1"
SRC=/var/www/$USER/public
DST=/var/www/$USER/.backups/public

if [ ! "$1" ] || [ ! -d $SRC ];
then
  echo "You have to set argument with valid site user for this script";
  exit 0;
fi

if [ ! -d $DST ]; then
  mkdir -p $DST
fi

LINK=""

if [ -L $DST/Latest ]; then
  LINK="--link-dest=$DST/Latest"
fi

rsync -ax \
--delete \
--exclude='.git/' \
$LINK \
$SRC $DST/Processing-$DATE \
&& cd $DST \
&& mv Processing-$DATE $DATE \
&& rm -f Latest \
&& ln -s $DATE Latest
