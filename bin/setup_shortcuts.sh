#!/bin/bash

echo "[`date +'%Y-%m-%d %H:%M:%S'`] Begin..."
LAST_DIR=`dirname $0`

# Define error handling function
handle_error()
{
  echo "[`date +'%Y-%m-%d %H:%M:%S'`] ERROR: $1" >&2
  exit 1
}

# Copy bootstrap files in /usr/bin
for S in `dirname $0`/../setup/usr/bin/*
do
  SHORTCUT_NAME=`basename $S`
  if test ! -f /usr/bin/$SHORTCUT_NAME
  then
    echo "Shortcut $SHORTCUT_NAME : installing /usr/bin/$SHORTCUT_NAME"
    sudo cp $S /usr/bin/$SHORTCUT_NAME
    sudo chmod +x /usr/bin/$SHORTCUT_NAME
  # else copy if modified
  fi
done

# Copy shortcuts in Desktop folders
MY_DESKTOP=$(xdg-user-dir DESKTOP 2>/dev/null)
if test -d "$MY_DESKTOP"
then
  echo "[`date +'%Y-%m-%d %H:%M:%S'`] Copy shortcuts to Desktop"
  if test ! -d ~/.local/share/applications/
  then
    mkdir ~/.local/share/applications/
  fi
  for S in $LAST_DIR/*.desktop
  do
    SHORTCUT_NAME=`basename $S`
    SHORTCUT_DIFF="0"
    if test -f "$MY_DESKTOP/$SHORTCUT_NAME"
    then
      diff $S "$MY_DESKTOP/$SHORTCUT_NAME" >/dev/null
      SHORTCUT_DIFF=$?
    else
      # No shortcut file : we need to install it
      SHORTCUT_DIFF=1
    fi
    if test "$SHORTCUT_DIFF" == "0"
    then
      echo "Shortcut $SHORTCUT_NAME : no changes"
    else
      echo "Shortcut $SHORTCUT_NAME : copying"
      cp $S "$MY_DESKTOP/$SHORTCUT_NAME"
      chmod u+x "$MY_DESKTOP/$SHORTCUT_NAME"
      cp $S ~/.local/share/applications/$SHORTCUT_NAME
      chmod u+x ~/.local/share/applications/$SHORTCUT_NAME
    fi
  done

fi

echo "[`date +'%Y-%m-%d %H:%M:%S'`] End."
