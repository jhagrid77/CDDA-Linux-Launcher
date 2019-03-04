#!/bin/bash

read -n 1 -p  "Would you like to install Cataclysm: Dark Days Ahead?" INSTALL
if [[ ( $INSTALL = 'Y' ) || ( $INSTALL = 'y' ) ]]
then
  read -n 1 -p "Would you like to install the [N]cures or [T]iles version? (Please enter N or T)" VERSION
  if [[ ( $VERSION = 'N' ) || ( $VERSION = 'n' ) ]]
  then
    echo "Installing needed dependencies."
    sudo apt-get update && sudo apt-get install astyle build-essential ccache clang git libglib2.0-dev liblua5.2-0 liblua5.2-dev libncurses5-dev libncursesw5-dev lua5.2 tmux -y
    read -n 1 -p "Would you like to choose a different font to use for the game? Doing so will create a launcher for you (Please enter Y or N)" FONT
    if [[ ( $FONT = 'Y' ) || ( $FONT = 'y' ) ]]
    then
      read -p "Please enter the absolute path you would like the launcher to be placed. If left blank, it will be placed in the current directory" LAUNCHER
      if [ -z $LAUNCHER ]
      then
        LAUNCHER=$(pwd)
      fi
      mkdir $LAUNCHER/backups
      echo -e 'ACTIVE_CONSOLES="/dev/tty[1-6]"\n' > $LAUNCHER/backups/game-font
      echo -e 'CHARMAP="UTF-8"\n' >> $LAUNCHER/backups/game-font
      echo 'CODESET="guess"' >> $LAUNCHER/backups/game-font
      echo 'FONTFACE="Terminus"' >> $LAUNCHER/backups/game-font
      echo -e 'FONTSIZE="14x28"\n' >> $LAUNCHER/backups/game-font
      echo 'VIDEOMODE=' >> $LAUNCHER/backups/game-font
      sudo chown root:root $LAUNCHER/backups/game-font
      sudo chmod 644 $LAUNCHER/backups/game-font

      echo "#!/bin/bash" > $LAUNCHER/cataclysm-launcher.sh
      echo "LAUNCHDIRECTORY=\$LAUNCHER" >> $LAUNCHER/cataclysm-launcher.sh
      echo "GAMEDIRECTORY=$(pwd)/Cataclysm-DDA"
      echo "echo 'Backing up current font.'" >> $LAUNCHER/cataclysm-launcher.sh
      echo "sudo cp /etc/default/console-setup \$LAUNCHDIRECTORY/backups/regular-font" >> $LAUNCHER/cataclysm-launcher.sh
      echo "sudo cp \$LAUNCHDIRECTORY/backups/game-font /etc/default/console-setup" >> $LAUNCHER/cataclysm-launcher.sh
      echo "cd \$GAMEDIRECTORY; ./cataclysm & PID=\$!" >> $LAUNCHER/cataclysm-launcher.sh
      echo "wait \$PID" >> $LAUNCHER/cataclysm-launcher.sh
      echo "sudo cp \$LAUNCHDIRECTORY/backups/regular-font /etc/default/console-setup" >> $LAUNCHER/cataclysm-launcher.sh
      echo "unset \LAUNCHDIRECTORY" >> $LAUNCHER/cataclysm-launcher.sh
      echo "unset \GAMEDIRECTORY" >> $LAUNCHER/cataclysm-launcher.sh
    fi
  elif [[ ( $VERSION = 'T' ) || ( $VERSION = 't' ) ]]
  then
    echo "Installing needed dependencies."
    sudo apt-get update && sudo apt-get install astyle build-essential ccache clang git libfreetype6-dev libglib2.0-dev liblua5.2-0 liblua5.2-dev libncurses5-dev libncursesw5-dev libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-ttf-dev lua5.2 -y

  fi
  echo "Downloading Cataclysm: DDA."
  git clone https://github.com/CleverRaven/Cataclysm-DDA.git
  cd Cataclysm-DDA

  echo "Compiling Cataclysm: DDA."
  make clean
  if [[ ( $VERSION = 'N' ) || ( $VERSION = 'n' ) ]]
  then
    make -j$(nproc --all) CLANG=1 CCACHE=1 RELEASE=1 LUA=1 USE_HOME_DIR=1
  elif [[ ( $VERSION = 'T' ) || ( $VERSION = 't' ) ]]
  then
    make -j$(nproc --all) CLANG=1 CCACHE=1 RELEASE=1 LUA=1 TILES=1 USE_HOME_DIR=1
  fi
fi

read -n 1 -p "Would you like to create an update script for "
echo "Creating an update script."
echo "#!/bin/sh" > update.sh
echo "cd ~/Cataclysm-DDA" >> update.sh
echo "git pull" >> update.sh
echo "make clean" >> update.sh
echo "make clean" >> update.sh
echo "make -j$(nproc --all) CLANG=1 CCACHE=1 RELEASE=1 LUA=1 USE_HOME_DIR=1" >> update.sh
chmod +x update.sh

unset INSTALL
unset VERSION
unset FONT
unset LAUNCHER
