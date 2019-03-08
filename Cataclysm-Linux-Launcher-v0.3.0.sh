#!/bin/bash

VERSION=0.3.0

RED="\033[0;31m"
BLUE="\033[0;34m"
GREEN="\033[1;32m"
ENDCOLOR="\033[0m"

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

ARCH=$(uname -m)

function run_cataclysm() {
  ./cataclysmdda/catalysm-launcher 2> ./cataclysmdda/cataclysm.log
}

function update_launcher() {
  echo "Checking for updates"
  wget -nc https://github.com/jhagrid77/CDDA-Ubuntu-Launcher/releases 2> /dev/null
  LATEST=$(cat releases | grep /jhagrid77/CDDA-Ubuntu-Launcher/releases/download | head -n 1 | tr '"' ' ' | awk '{print $3}' | awk -F "/" '{sub("v", ""); print $6}')
  VERSION_COMPARABLE=$(echo "$VERSION" | tr -d ".")
  LATEST_COMPARABLE=$(echo "$LATEST" | tr -d ".")
  rm ./releases

  if [[ "$VERSION_COMPARABLE" -ge "$LATEST_COMPARABLE" ]]
  then
    echo -e  $GREEN"Latest Version Verified"$ENDCOLOR
  else
    echo -e  $RED"Cataclysm-Linux-Launcher Version $VERSION_MAJOR.$VERSION_MINOR.$VERSION_PATCH is obsolete.  Latest version available is $LATEST"$ENDCOLOR
    read -n 1 -p "Would you like to update the Linux launcher to the latest version? (Please enter Y or N): " UPDATE
    echo ""
    if [[ ( "$UPDATE" = 'Y' ) || ( "$UPDATE" = 'y' ) ]]
    then
      wget -nc -q https://github.com/jhagrid77/CDDA-Ubuntu-Launcher/releases/download/v$LATEST/Cataclysm-Linux-Launcher-v"$LATEST".tar.gz
      tar -xvzf Cataclysm-Linux-Launcher-v"$LATEST".tar.gz
      chmod u+x ./Cataclysm-Linux-Launcher-v"$LATEST".sh
      exec ./Cataclysm-Linux-Launcher-v"$LATEST".sh
      exit 0
    fi
  fi
}

function install_cataclysm_compile() {
  true
}

function install_cataclysm_binary() {
  if [ "$ARCH" = 'x86_64' ]
  then
    wget -nc -q http://dev.narc.ro/cataclysm/jenkins-latest/Linux_x64/$1/
    INSTALLABLE=$(cat index.html | awk -F'"' '{print $6}' | grep -E "tar.gz")
    rm ./index.html
    while true
    do
      PS3="What version would you like to install?: "
      clear
      echo "Install Build Menu"
      select INSTALL in $INSTALLABLE "Go Back"
      do
        case "$INSTALL" in
          cataclysm* )
            if [ "$VER" = 'Ncurses' ]
            then
              echo "Installing needed dependencies"
              if [ "$OS" = 'Debian' ]
              then
                sudo apt-get update && sudo apt-get install -y astyle libglib2.0-0 lua5.2 ncurses-base
            elif [ "$OS" = 'Arch' ]
              then
                sudo pacman -Syy && sudo pacman -S --needed astyle glib2 lua ncurses
                sudo ln -s /usr/lib/liblua5.3.so /usr/lib/liblua5.3.so.0
                sudo ln -s /usr/lib/libncursesw.so.6.1 /usr/lib/libncursesw.so.5
                sudo ln -s /usr/lib/libtinfo.so.6 /usr/lib/libtinfo.so.5
            elif [ "$OS" = 'RPM-DNF' ]
              then
                sudo dnf install astyle.$ARCH glib2.$ARCH lua.$ARCH ncurses.$ARCH
                #elif [ "$OS" = 'RPM-YAST']
                #then
            elif [ "$OS" = 'RPM-YUM' ]
              then
                sudo yum install astyle.$ARCH glib2.$ARCH lua.$ARCH ncurses.$ARCH
              fi
            elif [ "$VER" = 'Tiles' ]
            then
              echo "Installing needed dependencies"
              if [ "$OS" = 'Debian' ]
              then
                sudo apt-get update && sudo apt-get install -y astyle libglib2.0-0 lua5.2 ncurses-base
            elif [ "$OS" = 'Arch' ]
              then
                sudo pacman -Syy && sudo pacman -S --needed astyle glib2 lua ncurses
                sudo ln -s /usr/lib/liblua5.3.so /usr/lib/liblua5.3.so.0
                sudo ln -s /usr/lib/libncursesw.so.6.1 /usr/lib/libncursesw.so.5
                sudo ln -s /usr/lib/libtinfo.so.6 /usr/lib/libtinfo.so.5
            elif [ "$OS" = 'RPM-DNF' ]
              then
                sudo dnf install astyle.$ARCH glib2.$ARCH lua.$ARCH ncurses.$ARCH
                #elif [ "$OS" = 'RPM-YAST']
                #then
            elif [ "$OS" = 'RPM-YUM' ]
              then
                sudo yum install astyle.$ARCH glib2.$ARCH lua.$ARCH ncurses.$ARCH
              fi
            fi
            wget -nc -q http://dev.narc.ro/cataclysm/jenkins-latest/Linux_x64/$1/$INSTALL
            MOVE=$(tar -tf $INSTALL)
            tar -xvzf $INSTALL
            rm $INSTALL
            mv $MOVE cataclysmdda/
            clear
            break
            ;;
          "Go Back" )
            break 2
            ;;
        esac
      done
    done
  fi
}

function update_cataclysm_compile() {
  true
}

function update_cataclysm_binary() {
  true
}

if [ $# = 0 ]
then
  while true
  do
    PS3="What would you like to do?: "
    clear
    echo "Main Menu"
    select QUESTION in "Cataclysm" "Backups" "Mods" "Tilesets" "Soundpacks" "Settings" "Update Launcher" "Quit"
    do
      case "$QUESTION" in
        "Cataclysm")
          while true
          do
            PS3="What would you like to do?: "
            clear
            echo "Cataclysm Menu"
            select QUESTION in "Install Cataclysm" "Compile Cataclysm" "Update Cataclysm" "Launch Cataclysm" "Go Back"
            do
              case "$QUESTION" in
                "Install Cataclysm")
                  while true
                  do
                    PS3="What version of the game would you like to install?: "
                    clear
                    echo "Install Menu"
                    select VER in "Ncurses" "Tiles" "Go Back"
                    do
                      case "$VER" in
                        "Ncurses")
                          install_cataclysm_binary Curses
                          clear
                          break
                          ;;
                        "Tiles")
                          install_cataclysm_binary Tiles
                          clear
                          break
                          ;;
                        "Go Back")
                          break 3
                          ;;
                      esac
                    done
                  done
                  ;;
                "Compile Cataclysm")
                  while true
                  do
                    PS3="What version of the game would you like to compile?: "
                    clear
                    echo "Compile Menu"
                    select VER in "Ncurses" "Tiles" "Go Back"
                    do
                      case "$VER" in
                        "Ncurses")
                          install_cataclysm_compile Ncurses
                          break
                          ;;
                        "Tiles")
                          install_cataclysm_compile Tiles
                          break
                          ;;
                        "Go Back")
                          break 3
                          ;;
                      esac
                    done
                  done
                  ;;
                "Launch Cataclysm")
                  run_cataclysm
                  break
                  ;;
                "Go Back")
                  break 3
                  ;;
              esac
            done
          done
          ;;
        "Update Launcher")
          update_launcher
          ;;
        "Quit")
          echo "Quiting the launcher."
          break 3
          ;;
        *) echo "Invalid response."
      esac
    done
  done
  #elif [[ $# -gt 0 ]]
  #then
fi

unset ARCH
unset BLUE
unset ENDCOLOR
unset GREEN
unset INSTALL
unset INSTALLABLE
unset LATEST
unset LATEST_COMPARABLE
unset MOVE
unset OS
unset PS3
unset QUESTION
unset RED
unset UPDATE
unset VER
unset VERSION_COMPARABLE
