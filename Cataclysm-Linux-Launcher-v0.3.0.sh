#!/bin/bash

VERSION=0.3.0

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
THREADS=$(($(nproc)/2))

if [ -f config.sh ]
then
  source ./config.sh
else
  touch ./config.sh
  chmod +x ./config.sh
fi

function run_cataclysm() {
  if [ "$INSTALL" = 'Binary' ]
  then
    ./cataclysmdda/cataclysm-launcher 2> ./cataclysmdda/cataclysm.log
elif [ "$INSTALL" = 'Compile' ]
  then
    ./Cataclysm-DDA/cataclysm-launcher 2> ./Cataclysm-DDA/cataclysm.log
  fi
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
    echo "Latest Version Verified"
  else
    echo "Cataclysm-Linux-Launcher Version $VERSION_MAJOR.$VERSION_MINOR.$VERSION_PATCH is obsolete.  Latest version available is $LATEST"
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
  if [ "$ARCH" = 'x86_64' ]
  then
    if [ "$VER" = 'Ncurses' ]
    then
      echo "Installing needed dependencies"
      if [ "$OS" = 'Debian' ]
      then
        sudo apt-get update && sudo apt-get install -y build-essential astyle clang ccache git zlib libglib2.0-0 lua5.2 ncurses-base
    elif [ "$OS" = 'Arch' ]
      then
        sudo pacman -Syy && sudo pacman -S --needed base-devel astyle glib2 lua ncurses
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
      git clone https://github.com/CleverRaven/Cataclysm-DDA.git
      cd ./Cataclysm-DDA
      make clean
      make -j $THREADS CLANG=1 CCACHE=1 LTO=1 LOCALIZE=0 RELEASE=1 LUA=1 USE_HOME_DIR=1
  elif [ "$VER" = 'Tiles' ]
    then
      echo "Installing needed dependencies"
      if [ "$OS" = 'Debian' ]
      then
        sudo apt-get update && sudo apt-get install -y astyle libglib2.0-0 lua5.2 ncurses-base
    elif [ "$OS" = 'Arch' ]
      then
        sudo pacman -Syy && sudo pacman -S --needed sdl2_mixer sdl_ttf sdl2_image sdl2 lua
    elif [ "$OS" = 'RPM-DNF' ]
      then
        sudo dnf install astyle.$ARCH glib2.$ARCH lua.$ARCH ncurses.$ARCH
        #elif [ "$OS" = 'RPM-YAST']
        #then
    elif [ "$OS" = 'RPM-YUM' ]
      then
        sudo yum install astyle.$ARCH glib2.$ARCH lua.$ARCH ncurses.$ARCH
      fi
      git clone https://github.com/CleverRaven/Cataclysm-DDA.git
      cd ./Cataclysm-DDA
      make clean
      make -j $THREADS CLANG=1 CCACHE=1 LTO=1 LOCALIZE=0 RELEASE=1 TILES=1 SOUND=1 LUA=1 USE_HOME_DIR=1
    fi
    sleep 5
  fi
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
      echo "Install Menu"
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
                sudo pacman -Syy && sudo pacman -S --needed sdl2_mixer sdl_ttf sdl2_image sdl2 lua
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
            MOVE=$(tar -tf $INSTALL | head -n 1)
            tar -xvzf $INSTALL
            rm $INSTALL
            mv $MOVE cataclysmdda/
            sleep 5
            unset $INSTALLABLE
            unset $INSTALL
            unset $MOVE
            source ./config.sh
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
  if [ "$VER" = 'Ncurses' ]
  then
    cd ./Cataclysm-DDA
    git pull
    make clean
    make -j $THREADS CLANG=1 CCACHE=1 LTO=1 LOCALIZE=0 RELEASE=1 LUA=1 USE_HOME_DIR=1
elif [ "$VER" = 'Tiles' ]
  then
    git clone https://github.com/CleverRaven/Cataclysm-DDA.git
    cd ./Cataclysm
    make clean
    make -j $THREADS CLANG=1 CCACHE=1 LTO=1 LOCALIZE=0 RELEASE=1 LUA=1 USE_HOME_DIR=1
  fi
}

function update_cataclysm_binary() {
  cd ./cataclysmdda
  mkdir previous_version
  mv ./* ./previous_version 2>/dev/null
  cd ..
  install_cataclysm_binary $VER
  cd ./cataclysmdda
  for i in "${ROLLBACK[@]}"
  do
    cp -r ./previous_version/$i ./
  done
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
                          if ! grep -q "^VER=" ./config.sh
                          then
                            echo "VER=$VER" | tee -a ./config.sh
                            source ./config.sh
                          fi
                          if [[ $(cat ./config.sh | grep "^VER=$VER") != VER=* ]]
                          then
                            sed -i "s|^VER=.*|VER=$VER|g" ./config.sh
                            source ./config.sh
                          fi
                          install_cataclysm_binary Curses
                          if ! grep -q "^INSTALL=" ./config.sh
                          then
                            echo "INSTALL=Binary" | tee -a ./config.sh
                            source ./config.sh
                          fi
                          if [[ $(cat ./config.sh | grep "^INSTALL=Binary") != INSTALL=* ]]
                          then
                            sed -i "s|^INSTALL=.*|INSTALL=Binary|g" ./config.sh
                            source ./config.sh
                          fi
                          clear
                          break
                          ;;
                        "Tiles")
                          if ! grep -q "^VER=" ./config.sh
                          then
                            echo "VER=$VER" | tee -a ./config.sh
                            source ./config.sh
                          fi
                          if [[ $(cat ./config.sh | grep "^VER=$VER") != VER=* ]]
                          then
                            sed -i "s|^VER=.*|VER=$VER|g" ./config.sh
                            source ./config.sh
                          fi
                          install_cataclysm_binary Tiles
                          if ! grep -q "^INSTALL=" ./config.sh
                          then
                            echo "INSTALL=Binary" | tee -a ./config.sh
                            source ./config.sh
                          fi
                          if [[ $(cat ./config.sh | grep "^INSTALL=Binary") != INSTALL=* ]]
                          then
                            sed -i "s|^INSTALL=.*|INSTALL=Binary|g" ./config.sh
                            source ./config.sh
                          fi
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
                          if ! grep -q "^VER=" ./config.sh
                          then
                            echo "VER=$VER" | tee -a ./config.sh
                            source ./config.sh
                          fi
                          if [[ $(cat ./config.sh | grep "^VER=$VER") != VER=* ]]
                          then
                            sed -i "s|^VER=.*|VER=$VER|g" ./config.sh
                            source ./config.sh
                          fi
                          install_cataclysm_compile Ncurses
                          if ! grep -q "^INSTALL=" ./config.sh
                          then
                            echo "INSTALL=Compile" | tee -a ./config.sh
                            source ./config.sh
                          fi
                          if [[ $(cat ./config.sh | grep "^INSTALL=Compile") != INSTALL=* ]]
                          then
                            sed -i "s|^INSTALL=.*|INSTALL=Compile|g" ./config.sh
                            source ./config.sh
                          fi
                          break
                          ;;
                        "Tiles")
                          if ! grep -q "^VER=" ./config.sh
                          then
                            echo "VER=$VER" | tee -a ./config.sh
                            source ./config.sh
                          fi
                          if [[ $(cat ./config.sh | grep "^VER=$VER") != VER=* ]]
                          then
                            sed -i "s|^VER=.*|VER=$VER|g" ./config.sh
                            source ./config.sh
                          fi
                          install_cataclysm_compile Tiles
                          if ! grep -q "^INSTALL=" ./config.sh
                          then
                            echo "INSTALL=Compile" | tee -a ./config.sh
                            source ./config.sh
                          fi
                          if [[ $(cat ./config.sh | grep "^INSTALL=Compile") != INSTALL=* ]]
                          then
                            sed -i "s|^INSTALL=.*|INSTALL=Compile|g" ./config.sh
                            source ./config.sh
                          fi
                          break
                          ;;
                        "Go Back")
                          break 3
                          ;;
                      esac
                    done
                  done
                  ;;
                "Update Cataclysm")
                  source ./config.sh
                  if [ "$INSTALL" = 'Binary' ]
                  then
                    update_cataclysm_binary
                  elif [ "$INSTALL" = 'Compile' ]
                  then
                    update_cataclysm_compile
                  fi
                  break
                  ;;
                "Launch Cataclysm")
                  source ./config.sh
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
        "Backup")
          ;;
        "Mods")
          ;;
        "Tilesets")
          ;;
        "Soundpacks")
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
  #   POSITIONAL=()
  #   while [[ $# -gt 0 ]]
  #   do
  #   key="$1"
  #
  #   case $key in
  #     -h|--help)
  #     echo "Possible arguments are:"
  #     shift # past argument
  #     shift # past value
  #     ;;
  #     -i|--install)
  #     INSTALL=$2
  #     shift # past argument
  #     shift # past value
  #     ;;
  #     -v|--version)
  #     VER="$2"
  #     shift # past argument
  #     shift # past value
  #     ;;
  #     -ul|--upgrade-launcher)
  #     shift # past argument
  #     shift # past value
  #     ;;
  #     -ug|--upgrade-game)
  #     shift # past argument
  #     shift # past value
  #     ;;
  #     *)    # unknown option
  #     POSITIONAL+=("$1") # save it in an array for later
  #     shift # past argument
  #     ;;
  # esac
  # done
  # set -- "${POSITIONAL[@]}" # restore positional parameters
  #then
fi

unset ARCH
unset INSTALL
unset INSTALLABLE
unset LATEST
unset LATEST_COMPARABLE
unset MOVE
unset OS
unset PS3
unset QUESTION
unset ROLLBACK
unset UPDATE
unset VER
unset VERSION
unset VERSION_COMPARABLE
