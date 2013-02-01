# Made by @jeydo
# https://github.com/jeydo
# 
#!/bin/bash
WIDTH="1920"
HEIGHT="1200"
IMAGE_PATH="$HOME/Images/"
SHUFFLE=""
DELETE_OLD=false

function usage {
  echo "
  Get a wallpaper from wlppr (new wallpaper everyday)

  Usage ./wlppr.sh [options...]
  Options:
  -h Help
  -w width, default 1920
  -H width, default 1200
  -s shuffle
  -d delete previous wallpaper
  -p path for files, default ~/Images"
}

while getopts hw:H:sdp: OPT; do
  case $OPT in
    h)
      usage
      exit
      ;;
    w)
      if [[ $OPTARG != *[!0-9]* ]]
      then
        WIDTH=$OPTARG
      else
        echo "Width must be an int"
        usage
        exit
      fi
      ;;
    H)
      if [[ $OPTARG != *[!0-9]* ]]
      then
        HEIGHT=$OPTARG
      else
        echo "Heigh must be an int"
        usage
        exit
      fi
      ;;
    s)
      SHUFFLE="shuffle"
      ;;
    d)
      DELETE_OLD=true
      ;;
    p)
      if [ -d $OPTARG ]
      then
        IMAGE_PATH=$OPTARG
      else
        echo "Path must be valid"
        usage
        exit
      fi
      ;;
  esac
done

TAILLE="${WIDTH}x${HEIGHT}"
OLD_FILE=`ls $IMAGE_PATH | grep $TAILLE`
URL="http://wlppr.com/$SHUFFLE"
LINK_IMAGE=`curl -s $URL | grep "$TAILLE" | sed "s/.*\"\(http:\/\/.*$TAILLE.jpg\)\".*/\1/"`

if [ !-n $LINK_IMAGE ]
then
  echo "Error while fetching the url"
  exit
fi

FILE="wlppr-`echo $LINK_IMAGE | sed "s/http:\/\/.*\/\(.*$TAILLE.jpg\)/\1/"`"

wget $LINK_IMAGE -O $IMAGE_PATH$FILE

if [ $? -eq 0 ]
then
  # cron  needs the DBUS_SESSION_BUS_ADDRESS environment variable set
  if [ -z "$DBUS_SESSION_BUS_ADDRESS" ] ; then
    TMP=~/.dbus/session-bus
    export $(grep -h DBUS_SESSION_BUS_ADDRESS= $TMP/$(ls -1t $TMP | head -n 1))
  fi
  /usr/bin/gsettings set org.gnome.desktop.background picture-uri "file://$IMAGE_PATH/$FILE"
  echo "New wallpaper set with success"
  if $DELETE_OLD && [ -f $IMAGE_PATH$OLD_FILE ]
  then
  rm -f $IMAGE_PATH$OLD_FILE
    if [ $? != 0 ]
    then
       echo "Error while deleting old wallpaper"
    else
       echo "Old wallpaper deleted with success"
    fi
  fi
else
  echo "Impossible to get the new wallpaper"
fi
