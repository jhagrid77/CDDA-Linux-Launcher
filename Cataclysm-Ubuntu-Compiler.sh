#!/bin/bash

if type apt-get >/dev/null 2>&1
then
  OS=Debian
elif type pacman >/dev/null 2>&1
then
  OS=Arch
elif type dnf >/dev/null 2>&1
then
  OS=RPM-DNF
  #elif type zypper >/dev/null 2>&1
  #then
  #  OS=RPM-ZYPPER
elif type yum >/dev/null 2>&1
then
  OS=RPM-YUM
fi

ARCH=$(uname -p)

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

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
      sudo apt-get update && sudo apt-get install astyle build-essential ccache clang git libglib2.0-dev liblua5.2-devel liblua5.3-dev libncurses5-dev libncursesw5-dev lua5.2 lua5.3 zip -y
  elif [ "$OS" = "Arch" ]
    then
      sudo pacman -Syy && sudo pacman -S --needed base-devel community/astyle ccache clang git glib2 lua ncurses zip
  elif [ "$OS" = "RPM-DNF" ]
    then
      if [ "$ARCH" = 'x86_64' ]
      then
        sudo dnf install astyle.$ARCH ccache.$ARCH clang.$ARCH git.$ARCH glib2.$ARCH lua.$ARCH lua-devel.$ARCH ncurses-devel.$ARCH zip.$ARCH
    elif [ "$ARCH" = 'i686' ]
      then
        sudo dnf install astyle.$ARCH clang.$ARCH git.$ARCH glib2.$ARCH lua.$ARCH lua-devel.$ARCH ncurses-devel.$ARCH zip.$ARCH
      fi
      #elif [ "$OS" = "RPM-ZYPPER" ]
      #then
  elif [ "$OS" = "RPM-YUM" ]
    then
      if [ "$ARCH" = 'x86_64' ]
      then
        sudo yum install astyle.$ARCH ccache.$ARCH clang.$ARCH git.$ARCH glib2.$ARCH lua.$ARCH lua-devel.$ARCH make.$ARCH ncurses-devel.$ARCH zip.$ARCH
    elif [ "$ARCH" = 'i686' ]
      then
        sudo yum install astyle.$ARCH clang.$ARCH git.$ARCH glib2.$ARCH lua.$ARCH lua-devel.$ARCH make.$ARCH ncurses-devel.$ARCH zip.$ARCH
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
        LAUNCHER=$DIR
      fi
      mkdir $LAUNCHER/backups
      if [ -f /etc/default/console-setup ]
      then
        sudo echo -e 'ACTIVE_CONSOLES="/dev/tty[1-6]"\n' | sudo tee $LAUNCHER/backups/game-font 1> /dev/null
        sudo echo -e 'CHARMAP="UTF-8"\n' | sudo tee -a $LAUNCHER/backups/game-font 1> /dev/null
        sudo echo 'CODESET="guess"' | sudo tee -a $LAUNCHER/backups/game-font 1> /dev/null
        sudo echo 'FONTFACE="Terminus"' | sudo tee -a $LAUNCHER/backups/game-font 1> /dev/null
        sudo echo -e 'FONTSIZE="14x28"\n' | sudo tee -a $LAUNCHER/backups/game-font 1> /dev/null
        sudo echo 'VIDEOMODE=' | sudo tee -a $LAUNCHER/backups/game-font 1> /dev/null
    elif [ -f /etc/vconsole.conf ]
      then
        if [ "$OS" = 'RPM-DNF' ]
        then
          sudo dnf install terminus-fonts-console
          #elif [ "$OS" = 'RPM-ZYPPER' ]
          #then
      elif [ "$OS" = 'RPM-YUM' ]
        then
          sudo yum install terminus-fonts-console
      elif [ "$OS" = 'Arch' ]
        then
          sudo pacman -S --needed terminus-font
        fi
        sudo echo 'KEYMAP="us"' | sudo tee $LAUNCHER/backups/game-font 1> /dev/null
        sudo echo 'FONT="ter-v32n"' | sudo tee -a $LAUNCHER/backups/game-font 1> /dev/null
      fi
      sudo chown root:root $LAUNCHER/backups/game-font
      sudo chmod 644 $LAUNCHER/backups/game-font

      echo "#!/bin/bash" > $LAUNCHER/cataclysm-launcher.sh
      echo "LAUNCHDIRECTORY=$LAUNCHER" >> $LAUNCHER/cataclysm-launcher.sh
      echo "GAMEDIRECTORY=$DIR/Cataclysm-DDA" >> $LAUNCHER/cataclysm-launcher.sh
      echo "echo 'Backing up current font.'" >> $LAUNCHER/cataclysm-launcher.sh
      if [ -f /etc/default/console-setup ]
      then
        echo "sudo cp /etc/default/console-setup \$LAUNCHDIRECTORY/backups/regular-font" >> $LAUNCHER/cataclysm-launcher.sh
        echo "sudo cp \$LAUNCHDIRECTORY/backups/game-font /etc/default/console-setup" >> $LAUNCHER/cataclysm-launcher.sh
    elif [ -f /etc/vconsole.conf ]
      then
        echo "sudo cp /etc/vconsole.conf \$LAUNCHDIRECTORY/backups/regular-font">> $LAUNCHER/cataclysm-launcher.sh
        echo "sudo cp \$LAUNCHDIRECTORY/backups/game-font /etc/vconsole.conf" >> $LAUNCHER/cataclysm-launcher.sh
        echo "sudo systemctl restart systemd-vconsole-setup.service" >> $LAUNCHER/cataclysm-launcher.sh
      fi
      echo "cd \$GAMEDIRECTORY; ./cataclysm" >> $LAUNCHER/cataclysm-launcher.sh
      if [ -f /etc/default/console-setup ]
      then
        echo "sudo cp \$LAUNCHDIRECTORY/backups/regular-font /etc/default/console-setup" >> $LAUNCHER/cataclysm-launcher.sh
    elif [ -f /etc/vconsole.conf ]
      then
        echo "sudo cp \$LAUNCHDIRECTORY/backups/regular-font /etc/vconsole.conf" >> $LAUNCHER/cataclysm-launcher.sh
        echo "sudo systemctl restart systemd-vconsole-setup.service" >> $LAUNCHER/cataclysm-launcher.sh
      fi
      echo "unset LAUNCHDIRECTORY" >> $LAUNCHER/cataclysm-launcher.sh
      echo "unset GAMEDIRECTORY" >> $LAUNCHER/cataclysm-launcher.sh
      chmod +x $LAUNCHER/cataclysm-launcher.sh
    fi
elif [[ ( "$VERSION" = 'T' ) || ( "$VERSION" = 't' ) ]]
  then
    echo "Installing needed dependencies."
    if [ "$OS" = 'Debian' ]
    then
      sudo apt-get update && sudo apt-get install astyle build-essential ccache clang git libfreetype6-dev liblua5.2-dev liblua5.3-dev libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-ttf-dev lua5.2 lua5.3 zip -y
  elif [ "$OS" = 'Arch' ]
    then
      sudo pacman -Syy && sudo pacman -S --needed base-devel bzip2 ccache clang community/astyle freetype2 gcc-libs git glibc lua sdl2 sdl2_image sdl2_mixer sdl2_ttf zip zlib
  elif [ "$OS" = 'RPM-DNF' ]
    then
      if [ "$ARCH" = 'x86_64' ]
      then
        sudo dnf install astyle.$ARCH bzip2.$ARCH ccache.$ARCH clang.$ARCH freetype.$ARCH git.$ARCH glibc.$ARCH lua.$ARCH make.$ARCH SDL2-devel.$ARCH SDL2_image-devel.$ARCH SDL2_mixer-devel.$ARCH SDL2_ttf-devel.$ARCH zip.$ARCH
    elif [ "$ARCH" = 'i686' ]
      then
        sudo dnf install astyle.$ARCH clang.$ARCH freetype.$ARCH git.$ARCH glibc.$ARCH lua.$ARCH make.$ARCH SDL2-devel.$ARCH SDL2_image-devel.$ARCH SDL2_mixer-devel.$ARCH SDL2_ttf-devel.$ARCH zip.$ARCH
      fi
      #elif [ "$OS" = 'RPM-ZYPPER' ]
      #then
  elif [ "$OS" = 'RPM-YUM' ]
    then
      if [ "$ARCH" = 'x86_64' ]
      then
        sudo yum install astyle.$ARCH bzip2.$ARCH ccache.$ARCH clang.$ARCH freetype.$ARCH git.$ARCH glibc.$ARCH lua.$ARCH make.$ARCH SDL2-devel.$ARCH SDL2_image-devel.$ARCH SDL2_mixer-devel.$ARCH SDL2_ttf-devel.$ARCH zip.$ARCH
    elif [ "$ARCH" = 'i686' ]
      then
        sudo yum install astyle.$ARCH clang.$ARCH freetype.$ARCH git.$ARCH glibc.$ARCH lua.$ARCH make.$ARCH SDL2-devel.$ARCH SDL2_image-devel.$ARCH SDL2_mixer-devel.$ARCH SDL2_ttf-devel.$ARCH zip.$ARCH
      fi
    fi
    if [ "$OS" = 'Debian' ]
    then
      GRAPHICS=$(dpkg -l 2>/dev/null | grep -E "xinit|wayland" | awk '{print $2}')
  elif [ "$OS" = 'Arch' ]
    then
      GRAPHICS=$(pacman -Q | awk '{print $1}' | grep -E "xinit|wayland")
  elif [ "$OS" = 'RPM-DNF' ]
    then
      GRAPHICS=$(dnf list installed | grep -E "xinit|wayland" | awk '{print $1}')
      #elif [ "$OS" = 'RPM-ZYPPER' ]
      #then
      #  GRAPHICS=$(rpm -qa | grep xinit | awk '{print $1}')
  elif [ "$OS" = 'RPM-YUM' ]
    then
      GRAPHICS=$(yum list installed | grep -E "xinit|wayland" | awk '{print $1}')
    fi
    if ! [[ ( "$GRAPHICS" =~ xinit ) || ( "$GRAPHICS" =~ wayland ) ]]
    then
      echo "It would appear that you do not have a graphical environment installed."
      read -n 1 -p "Would you like to install one now so you can play the Tiles version? (Please enter Y or N.) (If you select Y, then i3WM and Xorg will be installed): " GUI
      echo ""
      if [[ ( "$GUI" = 'Y' ) || ( "$GUI" = 'y' ) ]]
      then
        if [ "$OS" = 'Debian' ]
        then
          sudo apt-get update && sudo apt-get install i3 lightdm xinit x11-server-utils -y
      elif [ "$OS" = 'Arch' ]
        then
          sudo pacman -Syy && sudo pacman -S --needed i3 lightdm xinit
      elif [ "$OS" = 'RPM-DNF' ]
        then
          if [ "$ARCH" = 'x86_64' ]
          then
            sudo dnf install i3.$ARCH lightdm.$ARCH
        elif [ "$ARCH" = 'i686' ]
          then
            echo "Sorry, I couldn't find a way to install a GUI environment on a 32-bit system for!"
          fi
          #elif [ "$OS" = 'RPM-ZYPPER' ]
          #then
      elif [ "$OS" = 'RPM-YUM' ]
        then
          if [ "$ARCH" = 'x86_64' ]
          then
            sudo yum install i3.$ARCH lightdm.$ARCH
        elif [ "$ARCH" = 'i686' ]
          then
            echo "Sorry, I couldn't find a way to install a GUI environment on a 32-bit system for!"
          fi
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
        LAUNCHER=$DIR
      fi
      if [ -d $LAUNCHER/backups ]
      then
        mkdir $LAUNCHER/backups
      fi

      echo "Installing new font."
      mkdir temp
      cd temp
      wget https://www.fontsquirrel.com/fonts/download/white-rabbit
      mv white-rabbit white-rabbit.zip
      unzip white-rabbit.zip
      sudo mv whitrabt.ttf /usr/share/fonts/
      if type fc-cache >/dev/null 2>&1
      then
        fc-cache -f
      fi
      cd .. && rm -r temp
      echo "xterm*faceName: White Rabbit" > $LAUNCHER/backups/game-font
      echo "xterm*faceSize: 14" >> $LAUNCHER/backups/game-font
      echo "xterm*locale: true" >> $LAUNCHER/backups/game-font
      echo "xterm*loginshell: true" >> $LAUNCHER/backups/game-font
      echo "xterm*saveLines: 4096" >> $LAUNCHER/backups/game-font
      echo "xterm*showBlinkAsBold: true" >> $LAUNCHER/backups/game-font

      echo "#!/bin/bash" > $LAUNCHER/cataclysm-launcher.sh
      echo "LAUNCHDIRECTORY=$LAUNCHER" >> $LAUNCHER/cataclysm-launcher.sh
      echo "GAMEDIRECTORY=$DIR/Cataclysm-DDA" >> $LAUNCHER/cataclysm-launcher.sh
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
      echo "  rm -f ~/.Xresources" >> $LAUNCHER/cataclysm-launcher.sh
      echo "fi" >> $LAUNCHER/cataclysm-launcher.sh
      echo "unset LAUNCHDIRECTORY" >> $LAUNCHER/cataclysm-launcher.sh
      echo "unset GAMEDIRECTORY" >> $LAUNCHER/cataclysm-launcher.sh
      chmod +x $LAUNCHER/cataclysm-launcher.sh
    fi
  fi
  echo "Downloading Cataclysm: DDA."
  git clone --depth=1 https://github.com/CleverRaven/Cataclysm-DDA.git
  cd Cataclysm-DDA


  read -n 1 -p "Would you like the compiler to be silent/non-verbose? (This means no output during compiling) (Please enter Y or N): " SILENT
  echo ""
  read -n 1 -p "Would you like your data to be stored in your Home directory? (Please enter Y or N): " HOME
  echo ""
  echo "Compiling Cataclysm: DDA."
  make clean
  if [[ ( "$VERSION" = 'N' ) || ( "$VERSION" = 'n' ) ]]
  then
    if [[ "$OS" =~ 'RPM' ]]
    then
      if [ "$ARCH" = 'i686' ]
      then
        if [[ ( "$SILENT" = 'Y' ) || ( "$SILENT" = 'y' ) ]]
        then
          if [[ ( "$HOME" = 'Y' ) || ( "$HOME" = 'y' ) ]]
          then
            make -s -j$(nproc --all) CLANG=1 RELEASE=1 LUA=1 USE_HOME_DIR=1
        elif [[ ( "$HOME" = 'N' ) || ( "$HOME" = 'n' ) ]]
          then
            make -s -j$(nproc --all) CLANG=1 RELEASE=1 LUA=1
          fi
          if [[ ( "$SILENT" = 'N' ) || ( "$SILENT" = 'n' ) ]]
          then
            if [[ ( "$HOME" = 'Y' ) || ( "$HOME" = 'y' ) ]]
            then
              make -j$(nproc --all) CLANG=1 RELEASE=1 LUA=1 USE_HOME_DIR=1
          elif [[ ( "$HOME" = 'N' ) || ( "$HOME" = 'n' ) ]]
            then
              make -j$(nproc --all) CLANG=1 RELEASE=1 LUA=1
            fi
          fi
        fi
      fi
    else
      if [[ ( "$SILENT" = 'Y' ) || ( "$SILENT" = 'y' ) ]]
      then
        if [[ ( "$HOME" = 'Y' ) || ( "$HOME" = 'y' ) ]]
        then
          make -s -j$(nproc --all) CLANG=1 CCACHE=1 RELEASE=1 LUA=1 USE_HOME_DIR=1
      elif [[ ( "$HOME" = 'N' ) || ( "$HOME" = 'n' ) ]]
        then
          make -s -j$(nproc --all) CLANG=1 CCACHE=1 RELEASE=1 LUA=1
        fi
    elif [[ ( "$SILENT" = 'N' ) || ( "$SILENT" = 'n' ) ]]
      then
        if [[ ( "$HOME" = 'Y' ) || ( "$HOME" = 'y' ) ]]
        then
          make -j$(nproc --all) CLANG=1 CCACHE=1 RELEASE=1 LUA=1 USE_HOME_DIR=1
      elif [[ ( "$HOME" = 'N' ) || ( "$HOME" = 'n' ) ]]
        then
          make -j$(nproc --all) CLANG=1 CCACHE=1 RELEASE=1 LUA=1
        fi
      fi
    fi
elif [[ ( "$VERSION" = 'T' ) || ( "$VERSION" = 't' ) ]]
  then
    if [[ ( "$SILENT" = 'Y' ) || ( "$SILENT" = 'y' ) ]]
    then
      if [[ ( "$HOME" = 'Y' ) || ( "$HOME" = 'y' ) ]]
      then
        make -s -j$(nproc --all) CLANG=1 CCACHE=1 RELEASE=1 TILES=1 SOUND=1 LUA=1 USE_HOME_DIR=1
    elif [[ ( "$HOME" = 'N' ) || ( "$HOME" = 'n' ) ]]
      then
        make -s -j$(nproc --all) CLANG=1 CCACHE=1 RELEASE=1 TILES=1 SOUND=1 LUA=1
      fi
  elif [[ ( "$SILENT" = 'N' ) || ( "$SILENT" = 'n' ) ]]
    then
      if [[ ( "$HOME" = 'Y' ) || ( "$HOME" = 'y' ) ]]
      then
        make -j$(nproc --all) CLANG=1 CCACHE=1 RELEASE=1 TILES=1 SOUND=1 LUA=1 USE_HOME_DIR=1
    elif [[ ( "$HOME" = 'N' ) || ( "$HOME" = 'n' ) ]]
      then
        make -j$(nproc --all) CLANG=1 CCACHE=1 RELEASE=1 TILES=1 SOUND=1 LUA=1
      fi
    fi
  fi
fi

read -n 1 -p "Would you like to create an update script for Cataclysm: Dark Days Ahead? (Please enter Y or N): " UPDATE
echo ""
if [[ ( "$UPDATE" = 'Y' ) || ( "$UPDATE" = 'y' )]]
then
  if [ -z $LAUNCHER ]
  then
    read -p "Please enter the absolute path you would like the updater to be placed. If left blank, it will be placed in the current directory: " LAUNCHER
    echo ""
    if [ -z $LAUNCHER ]
    then
      LAUNCHER=$DIR
    fi
  fi
  if [ -z $VERSION ]
  then
    read -n 1 -p "Would you like to install the updater for the [N]curses or [T]iles version? (Please enter N or T): " VERSION
    echo ""
  fi
  if [ -z $SILENT ]
  then
    read -n 1 -p "Would you like the compiler to be silent/non-verbose? (This means no output during compiling) (Please enter Y or N): " SILENT
    echo ""
  fi
  if [ -z $HOME ]
  then
    read -n 1 -p "Would you like your data to be stored in your Home directory? (Please enter Y or N): " HOME
    echo ""
  fi
  echo "#!/bin/bash" > $LAUNCHER/cataclysm-updater.sh
  echo "GAMEDIRECTORY=$DIR/Cataclysm-DDA" >> $LAUNCHER/cataclysm-updater.sh
  echo "cd \$GAMEDIRECTORY" >> $LAUNCHER/cataclysm-updater.sh
  echo "git pull" >> $LAUNCHER/cataclysm-updater.sh
  echo "make clean" >> $LAUNCHER/cataclysm-updater.sh
  if [[ ( "$VERSION" = 'N' ) || ( "$VERSION" = 'n' ) ]]
  then
    if [[ "$OS" =~ 'RPM' ]]
    then
      if [ "$ARCH" = 'i686' ]
      then
        if [[ ( "$SILENT" = 'Y' ) || ( "$SILENT" = 'y' ) ]]
        then
          if [[ ( "$HOME" = 'Y' ) || ( "$HOME" = 'y' ) ]]
          then
            echo "make -s -j$(nproc --all) CLANG=1 RELEASE=1 LUA=1 USE_HOME_DIR=1" >> $LAUNCHER/cataclysm-updater.sh
        elif [[ ( "$HOME" = 'N' ) || ( "$HOME" = 'n' ) ]]
          then
            echo "make -s -j$(nproc --all) CLANG=1 RELEASE=1 LUA=1" >> $LAUNCHER/cataclysm-updater.sh
          fi
          if [[ ( "$SILENT" = 'N' ) || ( "$SILENT" = 'n' ) ]]
          then
            if [[ ( "$HOME" = 'Y' ) || ( "$HOME" = 'y' ) ]]
            then
              echo "make -j$(nproc --all) CLANG=1 RELEASE=1 LUA=1 USE_HOME_DIR=1" >> $LAUNCHER/cataclysm-updater.sh
          elif [[ ( "$HOME" = 'N' ) || ( "$HOME" = 'n' ) ]]
            then
              echo "make -j$(nproc --all) CLANG=1 RELEASE=1 LUA=1" >> $LAUNCHER/cataclysm-updater.sh
            fi
          fi
        fi
      fi
    else
      if [[ ( "$SILENT" = 'Y' ) || ( "$SILENT" = 'y' ) ]]
      then
        if [[ ( "$HOME" = 'Y' ) || ( "$HOME" = 'y' ) ]]
        then
          echo "make -s -j$(nproc --all) CLANG=1 CCACHE=1 RELEASE=1 LUA=1 USE_HOME_DIR=1" >> $LAUNCHER/cataclysm-updater.sh
      elif [[ ( "$HOME" = 'N' ) || ( "$HOME" = 'n' ) ]]
        then
          echo "make -s -j$(nproc --all) CLANG=1 CCACHE=1 RELEASE=1 LUA=1" >> $LAUNCHER/cataclysm-updater.sh
        fi
    elif [[ ( "$SILENT" = 'N' ) || ( "$SILENT" = 'n' ) ]]
      then
        if [[ ( "$HOME" = 'Y' ) || ( "$HOME" = 'y' ) ]]
        then
          echo "make -j$(nproc --all) CLANG=1 CCACHE=1 RELEASE=1 LUA=1 USE_HOME_DIR=1"
      elif [[ ( "$HOME" = 'N' ) || ( "$HOME" = 'n' ) ]]
        then
          echo "make -j$(nproc --all) CLANG=1 CCACHE=1 RELEASE=1 LUA=1" >> $LAUNCHER/cataclysm-updater.sh
        fi
      fi
    fi
elif [[ ( "$VERSION" = 'T' ) || ( "$VERSION" = 't' ) ]]
  then
    if [[ ( "$SILENT" = 'Y' ) || ( "$SILENT" = 'y' ) ]]
    then
      if [[ ( "$HOME" = 'Y' ) || ( "$HOME" = 'y' ) ]]
      then
        echo "make -s -j$(nproc --all) CLANG=1 CCACHE=1 RELEASE=1 TILES=1 SOUND=1 LUA=1 USE_HOME_DIR=1" >> $LAUNCHER/cataclysm-updater.sh
    elif [[ ( "$HOME" = 'N' ) || ( "$HOME" = 'n' ) ]]
      then
        echo "make -s -j$(nproc --all) CLANG=1 CCACHE=1 RELEASE=1 TILES=1 SOUND=1 LUA=1" >> $LAUNCHER/cataclysm-updater.sh
      fi
  elif [[ ( "$SILENT" = 'N' ) || ( "$SILENT" = 'n' ) ]]
    then
      if [[ ( "$HOME" = 'Y' ) || ( "$HOME" = 'y' ) ]]
      then
        echo "make -j$(nproc --all) CLANG=1 CCACHE=1 RELEASE=1 TILES=1 SOUND=1 LUA=1 USE_HOME_DIR=1" >> $LAUNCHER/cataclysm-updater.sh
    elif [[ ( "$HOME" = 'N' ) || ( "$HOME" = 'n' ) ]]
      then
        echo "make -j$(nproc --all) CLANG=1 CCACHE=1 RELEASE=1 TILES=1 SOUND=1 LUA=1" >> $LAUNCHER/cataclysm-updater.sh
      fi
    fi
  fi
  chmod +x $LAUNCHER/cataclysm-updater.sh
fi

unset ARCH
unset FONT
unset GRAPHICS
unset GUI
unset HOME
unset INSTALL
unset LAUNCHER
unset OS
unset SILENT
unset UPDATE
unset VERSION
