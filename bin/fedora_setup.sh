#!/bin/sh

echo Last update 2/5/14 for Fedora 20

if [[ $UID -ne 0 ]]
then
  echo "Please run this script as root (sudo $0)"
  exit 1
fi

LOGFILE=fedora_setup_$(date +'%Y%m%d%H%M').log
date > $LOGFILE

# Get system architecture (i686 or x86_64)
ARCH=$HOSTTYPE

say() {
  echo "================================================================================================="
  echo "$*"
  echo "================================================================================================="
}

install() {
  echo "Install $* ? [y/N]"
  read answer
  if [ "x$answer" = "xy" ]
  then
    yum -y install $* >> $LOGFILE
  fi
}


say "My standard Fedora software installs..."

say Speed up downloads
install yum-plugin-fastestmirror

say Still my favorite editor
install nedit

say Set up RPMFusion for MP3 support
yum localinstall --nogpgcheck http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

say Thunderbird e-mail
install thunderbird

say Music players
install xmms xmms-mp3 xmms-faad2 xmms-flac xmms-pulse xmms-skins
install rhythmbox gstreamer-plugins-ugly gstreamer-plugins-bad gstreamer-ffmpeg gstreamer-plugins-bad-nonfree

say Media players
install mplayer mplayer-gui gecko-mediaplayer mencoder
install xine xine-lib-extras xine-lib-extras-freeworld
install vlc

#say Microsoft Trutype Fonts
#wget http://www.mjmwired.net/resources/files/msttcore-fonts-2.0-3.noarch.rpm
#rpm -ivh msttcore-fonts-2.0-3.noarch.rpm


say Adobe Flash
if [ $ARCH = "i686" ] # Adobe uses i386 for 32-bit not i686
then
  ARCH2="i386"
else
  ARCH2=$ARCH
fi

rpm -ivh http://linuxdownload.adobe.com/adobe-release/adobe-release-${ARCH2}-1.0-1.noarch.rpm
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-adobe-linux
yum check-update
install flash-plugin nspluginwrapper alsa-plugins-pulseaudio libcurl

say Adobe Reader
rpm -ivh http://linuxdownload.adobe.com/adobe-release/adobe-release-i386-1.0-1.noarch.rpm
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-adobe-linux
install AdobeReader_enu

say dconf-editor for changing window focus
install dconf-editor

say Recommended by fedorafaq.org for viewing PDFs and movies in Firefox
install mozplugger xpdf totem-mozplugin gstreamer-plugins-bad gstreamer-plugins-ugly



say "Finished.  See output in $LOGFILE"

