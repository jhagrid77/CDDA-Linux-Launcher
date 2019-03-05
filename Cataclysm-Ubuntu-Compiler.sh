#!/bin/bash

if type apt-get >/dev/null 2>&1
then
  OS=Debian
elif type pacman >/dev/null 2>&1
then
  OS=Arch
  #elif type rpm >/dev/null 2>&1
  #then
  #  OS=RPM
fi

read -n 1 -p  "Would you like to install Cataclysm: Dark Days Ahead? You can choose to install the updater script either way. (Please enter Y or N): " INSTALL
echo ""
if [[ ( "$INSTALL" = 'Y' ) || ( "$INSTALL" = 'y' ) ]]
then
  read -n 1 -p "Would you like to install the [N]curses or [T]iles version? (Please enter N or T): " VERSION
  echo ""
  if [[ ( "$VERSION" = 'N' ) || ( "$VERSION" = 'n' ) ]]
  then
    echo "Installing needed dependencies."
    if [ "$OS" = "Debian" ]
    then
      sudo apt-get update && sudo apt-get install astyle build-essential ccache clang git libglib2.0-dev liblua5.3-dev libncurses5-dev libncursesw5-dev lua5.3 zip -y
  elif [ "$OS" = "Arch" ]
    then
      sudo pacman -Syy && sudo pacman -S astyle ccache clang git glib2 lua lua52 ncurses zip
      #elif [ "$OS" = "RPM" ]
      #then
    fi
    read -n 1 -p "Would you like to choose a different font to use for the game? Doing so will create a launcher for you (Please enter Y or N): " FONT
    echo ""
    if [[ ( "$FONT" = 'Y' ) || ( "$FONT" = 'y' ) ]]
    then
      read -p "Please enter the absolute path you would like the launcher to be placed. If left blank, it will be placed in the current directory: " LAUNCHER
      echo ""
      if [ -z $LAUNCHER ]
      then
        LAUNCHER=$(pwd)
      fi
      mkdir $LAUNCHER/backups
      sudo echo -e 'ACTIVE_CONSOLES="/dev/tty[1-6]"\n' | sudo tee $LAUNCHER/backups/game-font 1> /dev/null
      sudo echo -e 'CHARMAP="UTF-8"\n' | sudo tee -a $LAUNCHER/backups/game-font 1> /dev/null
      sudo echo 'CODESET="guess"' | sudo tee -a $LAUNCHER/backups/game-font 1> /dev/null
      sudo echo 'FONTFACE="Terminus"' | sudo tee -a $LAUNCHER/backups/game-font 1> /dev/null
      sudo echo -e 'FONTSIZE="14x28"\n' | sudo tee -a $LAUNCHER/backups/game-font 1> /dev/null
      sudo echo 'VIDEOMODE=' | sudo tee -a $LAUNCHER/backups/game-font 1> /dev/null
      sudo chown root:root $LAUNCHER/backups/game-font
      sudo chmod 644 $LAUNCHER/backups/game-font

      echo "#!/bin/bash" > $LAUNCHER/cataclysm-launcher.sh
      echo "LAUNCHDIRECTORY=$LAUNCHER" >> $LAUNCHER/cataclysm-launcher.sh
      echo "GAMEDIRECTORY=$(pwd)/Cataclysm-DDA" >> $LAUNCHER/cataclysm-launcher.sh
      echo "echo 'Backing up current font.'" >> $LAUNCHER/cataclysm-launcher.sh
      echo "sudo cp /etc/default/console-setup \$LAUNCHDIRECTORY/backups/regular-font" >> $LAUNCHER/cataclysm-launcher.sh
      echo "sudo cp \$LAUNCHDIRECTORY/backups/game-font /etc/default/console-setup" >> $LAUNCHER/cataclysm-launcher.sh
      echo "cd \$GAMEDIRECTORY; ./cataclysm" >> $LAUNCHER/cataclysm-launcher.sh
      echo "sudo cp \$LAUNCHDIRECTORY/backups/regular-font /etc/default/console-setup" >> $LAUNCHER/cataclysm-launcher.sh
      echo "unset LAUNCHDIRECTORY" >> $LAUNCHER/cataclysm-launcher.sh
      echo "unset GAMEDIRECTORY" >> $LAUNCHER/cataclysm-launcher.sh
      chmod +x $LAUNCHER/cataclysm-launcher.sh
    fi
elif [[ ( "$VERSION" = 'T' ) || ( "$VERSION" = 't' ) ]]
  then
    echo "Installing needed dependencies."
    if [ "$OS" = 'Debian' ]
    then
      sudo apt-get update && sudo apt-get install build-essential ccache clang git libfreetype6-dev liblua5.3-dev libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-ttf-dev lua5.3 zip -y
  elif [ "$OS" = 'Arch' ]
    then
      sudo pacman -Syy && sudo pacman -S base-devel bzip2 ccache clang freetype2 gcc-libs git glibc lua sdl2 sdl2_image sdl2_mixer sdl2_ttf zip zlib
      #elif [ "$OS" = 'RPM' ]
      #then
    fi
    if [ "$OS" = 'Debian' ]
    then
      GRAPHICS=$(dpkg -l 2>/dev/null | grep "xinit" | awk '{print $2}')
  elif [ "$OS" = 'Arch' ]
    then
      GRAPHICS=$(pacman -Q | awk '{print $1}' | grep "xinit")
      #elif [ "$OS" = 'RPM' ]
      #then
    fi
    if ! [[ "$GRAPHICS" =~ xinit ]]
    then
      echo "It would appear that you do not have a graphical environment installed."
      read -n 1 -p "Would you like to install one now so you can play the Tiles version? (Please enter Y or N.) (If you select Y, then i3WM and Xorg will be installed): " GUI
      echo ""
      if [[ ( "$GUI" = 'Y' ) || ( "$GUI" = 'y' ) ]]
      then
        if [ "$OS" = 'Debian' ]
        then
          sudo apt-get update && sudo apt-get install i3 lightdm xinit x11-server-utils -y
        fi
        if [ "$OS" = 'Arch' ]
        then
          sudo pacman -Syy && sudo pacman -S i3 lightdm xinit
          #elif [ "$OS" = 'RPM' ]
          #then
        fi
    elif  [[ ( "$GUI" = 'N' ) || ( "$GUI" = 'n' ) ]]
      then
        echo "Sorry, the Tiles version of C:DDA cannot work without a GUI."
        exit
      fi
    fi
    read -n 1 -p "Would you like to choose a different font to use for the game? Doing so will create a launcher for you (Please enter Y or N): " FONT
    echo ""
    if [[ ( "$FONT" = 'Y' ) || ( "$FONT" = 'y' ) ]]
    then
      read -p "Please enter the absolute path you would like the launcher to be placed. If left blank, it will be placed in the current directory: " LAUNCHER
      echo ""
      if [ -z $LAUNCHER ]
      then
        LAUNCHER=$(pwd)
      fi
      mkdir $LAUNCHER/backups

      echo "Installing new font."
      mkdir temp
      cd temp
      wget https://www.fontsquirrel.com/fonts/download/white-rabbit
      mv white-rabbit white-rabbit.zip
      unzip white-rabbit.zip
      sudo mv whitrabt.ttf /usr/local/share/fonts/
      cd .. && rm -r temp
      echo "xterm*faceName: White Rabbit" > $LAUNCHER/backups/game-font
      echo "xterm*faceSize: 14" >> $LAUNCHER/backups/game-font
      echo "xterm*locale: true" >> $LAUNCHER/backups/game-font
      echo "xterm*loginshell: true" >> $LAUNCHER/backups/game-font
      echo "xterm*saveLines: 4096" >> $LAUNCHER/backups/game-font
      echo "xterm*showBlinkAsBold: true" >> $LAUNCHER/backups/game-font

      echo "#!/bin/bash" > $LAUNCHER/cataclysm-launcher.sh
      echo "LAUNCHDIRECTORY=$LAUNCHER" >> $LAUNCHER/cataclysm-launcher.sh
      echo "GAMEDIRECTORY=$(pwd)/Cataclysm-DDA" >> $LAUNCHER/cataclysm-launcher.sh
      echo "if [ -f ~/.Xresources ]" >> $LAUNCHER/cataclysm-launcher.sh
      echo "then" >> $LAUNCHER/cataclysm-launcher.sh
      echo "  echo 'Backing up current font.'" >> $LAUNCHER/cataclysm-launcher.sh
      echo "  cp ~/.Xresources \$LAUNCHDIRECTORY/backups/regular-font" >> $LAUNCHER/cataclysm-launcher.sh
      echo "fi" >> $LAUNCHER/cataclysm-launcher.sh
      echo "sudo cp \$LAUNCHDIRECTORY/backups/game-font ~/.Xresources" >> $LAUNCHER/cataclysm-launcher.sh
      echo "cd \$GAMEDIRECTORY; ./cataclysm-launcher" >> $LAUNCHER/cataclysm-launcher.sh
      echo "if [ -f \$LAUNCHDIRECTORY/backups/regular-font ]" >> $LAUNCHER/cataclysm-launcher.sh
      echo "then" >> $LAUNCHER/cataclysm-launcher.sh
      echo "  echo 'Restoring regular font.'" >> $LAUNCHER/cataclysm-launcher.sh
      echo "  cp \$LAUNCHDIRECTORY/backups/regular-font ~/.Xresources" >> $LAUNCHER/cataclysm-launcher.sh
      echo "else" >> $LAUNCHER/cataclysm-launcher.sh
      echo "  rm ~/.Xresources" >> $LAUNCHER/cataclysm-launcher.sh
      echo "fi" >> $LAUNCHER/cataclysm-launcher.sh
      echo "unset LAUNCHDIRECTORY" >> $LAUNCHER/cataclysm-launcher.sh
      echo "unset GAMEDIRECTORY" >> $LAUNCHER/cataclysm-launcher.sh
      chmod +x $LAUNCHER/cataclysm-launcher.sh
    fi
  fi
  echo "Downloading Cataclysm: DDA."
  git clone --depth=1 https://github.com/CleverRaven/Cataclysm-DDA.git
  cd Cataclysm-DDA

  echo "Compiling Cataclysm: DDA."
  make clean
  if [[ ( "$VERSION" = 'N' ) || ( "$VERSION" = 'n' ) ]]
  then
    make -s -j$(nproc --all) CLANG=1 CCACHE=1 RELEASE=1 LUA=1 USE_HOME_DIR=1
elif [[ ( "$VERSION" = 'T' ) || ( "$VERSION" = 't' ) ]]
  then
    make -s -j$(nproc --all) CLANG=1 CCACHE=1 RELEASE=1 LUA=1 TILES=1 USE_HOME_DIR=1
  fi
fi

read -n 1 -p "Would you like to create an update script for Cataclysm: Dark Days Ahead?: " UPDATE
echo ""
if [[ ( "$UPDATE" = 'Y' ) || ( "$UPDATE" = 'y' )]]
then
  if [ -z $LAUNCHER ]
  then
    read -p "Please enter the absolute path you would like the updater to be placed. If left blank, it will be placed in the current directory: " LAUNCHER
    echo ""
    if [ -z $LAUNCHER ]
    then
      LAUNCHER=$(pwd)
    fi
  fi
  if [ -z $VERSION ]
  then
    read -n 1 -p "Would you like to install the updater for the [N]curses or [T]iles version? (Please enter N or T): " VERSION
    echo ""
  fi
  echo "#!/bin/bash" > $LAUNCHER/cataclysm-updater.sh
  echo "GAMEDIRECTORY=$(pwd)/Cataclysm-DDA" >> $LAUNCHER/cataclysm-updater.sh
  echo "cd \$GAMEDIRECTORY" >> $LAUNCHER/cataclysm-updater.sh
  echo "git pull" >> $LAUNCHER/cataclysm-updater.sh
  echo "make clean" >> $LAUNCHER/cataclysm-updater.sh
  if [[ ( "$VERSION" = 'N' ) || ( "$VERSION" = 'n' ) ]]
  then
    echo "make -s -j$(nproc --all) CLANG=1 CCACHE=1 RELEASE=1 LUA=1 USE_HOME_DIR=1" >> $LAUNCHER/cataclysm-updater.sh
elif [[ ( "$VERSION" = 'T' ) || ( "$VERSION" = 't' ) ]]
  then
    echo "make -s -j$(nproc --all) CLANG=1 CCACHE=1 RELEASE=1 LUA=1 TILES=1 USE_HOME_DIR=1" >> $LAUNCHER/cataclysm-updater.sh
  fi
  chmod +x $LAUNCHER/cataclysm-updater.sh
fi

unset INSTALL
unset VERSION
unset FONT
unset LAUNCHER
unset UPDATE
unset GUI
unset OS
