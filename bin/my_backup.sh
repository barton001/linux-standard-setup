#!/bin/sh

today=`date +"%Y%m%d"`

# Grab a copy of important config files so they'll  be included in backup
cp /etc/fstab /etc/hosts /home/barton/etc

# Backup home directory, skipping the 'dot' directories but including .bashrc & other bash init scripts
tar -vczf /Blinkstation/Backups/Linux/dell-laptop/${today}_home.tgz /home/barton \
  --exclude='.a*' --exclude='.bluefish*' --exclude='.[c-z]*' \
  --exclude='Downloads' --exclude='sw'
  
# Backup website directory
cd /var/www/html/bhbsoftware
tar -vczf /Blinkstation/Backups/Linux/dell-laptop/${today}_bhbsoftware.tgz .


