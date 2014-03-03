#!/bin/bash
#
# Currently running this from root's cron job. Otherwise rsync fails to
# copy files.
#

DEST=/Blinkstation/Backups/Linux/$HOSTNAME
SRC=/home/barton
rsync $SRC/* $SRC/.* $DEST/
rsync -avz $SRC/bin $SRC/etc $SRC/ccode $SRC/Python $SRC/scripts $DEST

