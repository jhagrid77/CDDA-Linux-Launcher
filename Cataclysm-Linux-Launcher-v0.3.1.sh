#!/bin/bash

version=0.3.1

if type apt-get >/dev/null 2>&1
then
  os=Debian
elif type pacman >/dev/null 2>&1
then
  os=Arch
elif type dnf >/dev/null 2>&1
then
  os=RPM-DNF
  #elif type zypper >/dev/null 2>&1
  #then
  #  os=RPM-ZYPPER
elif type yum >/dev/null 2>&1
then
  os=RPM-YUM
fi

arch=$(uname -m)
threads=$(($(nproc)/2))

if [ -f config.sh ]
then
  source ./config.sh
else
  touch ./config.sh
  chmod +x ./config.sh
fi

function run_cataclysm() {
  if [ "$install" = 'Binary' ]
  then
    ./cataclysmdda/cataclysm-launcher 2> ./cataclysmdda/cataclysm.log
elif [ "$install" = 'Compile' ]
  then
    ./Cataclysm-DDA/cataclysm-launcher 2> ./Cataclysm-DDA/cataclysm.log
  fi
}

function update_launcher() {
  echo "Checking for updates"
  wget -nc https://github.com/jhagrid77/CDDA-Ubuntu-Launcher/releases 2> /dev/null
  latest=$(cat releases | grep /jhagrid77/CDDA-Ubuntu-Launcher/releases/download | head -n 1 | tr '"' ' ' | awk '{print $3}' | awk -F "/" '{sub("v", ""); print $6}')
  function version_gt() { test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"; }
  rm ./releases

  if ! [[ "$version" = "$latest " ]]
  then
    if version_gt $version $latest
    then
      echo "Latest Version Verified"
    else
      echo "Cataclysm-Linux-Launcher Version $version is obsolete.  Latest version available is $latest"
      read -n 1 -p "Would you like to update the Linux launcher to the latest version? (Please enter Y or N): " update
      echo ""
      if [[ ( "$update" = 'Y' ) || ( "$update" = 'y' ) ]]
      then
        wget -nc -q https://github.com/jhagrid77/CDDA-Ubuntu-Launcher/releases/download/v$latest/Cataclysm-Linux-Launcher-v"$latest".tar.gz
        tar -xvzf Cataclysm-Linux-Launcher-v"$latest".tar.gz
        chmod u+x ./Cataclysm-Linux-Launcher-v"$latest".sh
        exec ./Cataclysm-Linux-Launcher-v"$latest".sh
        exit 0
      fi
    fi
  fi
}

function install_cataclysm_compile() {
  if [ "$arch" = 'x86_64' ]
  then
    if [ "$ver" = 'Ncurses' ]
    then
      echo "Installing needed dependencies"
      if [ "$os" = 'Debian' ]
      then
        sudo apt-get update && sudo apt-get install -y build-essential astyle clang ccache git zlib libglib2.0-0 ncurses-base
    elif [ "$os" = 'Arch' ]
      then
        sudo pacman -Syy && sudo pacman -S --needed base-devel astyle glib2 ncurses
        sudo ln -s /usr/lib/libncursesw.so.6.1 /usr/lib/libncursesw.so.5
        sudo ln -s /usr/lib/libtinfo.so.6 /usr/lib/libtinfo.so.5
    elif [ "$os" = 'RPM-DNF' ]
      then
        sudo dnf install astyle.$arch glib2.$arch ncurses.$arch
        #elif [ "$os" = 'RPM-YAST']
        #then
    elif [ "$os" = 'RPM-YUM' ]
      then
        sudo yum install astyle.$arch glib2.$arch ncurses.$arch
      fi
      git clone https://github.com/CleverRaven/Cataclysm-DDA.git
      cd ./Cataclysm-DDA
      make clean
      make -j $threads CLANG=1 CCACHE=1 LTO=1 LOCALIZE=0 RELEASE=1 USE_HOME_DIR=1
  elif [ "$ver" = 'Tiles' ]
    then
      echo "Installing needed dependencies"
      if [ "$os" = 'Debian' ]
      then
        sudo apt-get update && sudo apt-get install -y astyle libglib2.0-0 ncurses-base
    elif [ "$os" = 'Arch' ]
      then
        sudo pacman -Syy && sudo pacman -S --needed sdl2_mixer sdl_ttf sdl2_image sdl2
    elif [ "$os" = 'RPM-DNF' ]
      then
        sudo dnf install astyle.$arch glib2.$arch ncurses.$arch
        #elif [ "$os" = 'RPM-YAST']
        #then
    elif [ "$os" = 'RPM-YUM' ]
      then
        sudo yum install astyle.$arch glib2.$arch ncurses.$arch
      fi
      git clone https://github.com/CleverRaven/Cataclysm-DDA.git
      cd ./Cataclysm-DDA
      make clean
      make -j $threads CLANG=1 CCACHE=1 LTO=1 LOCALIZE=0 RELEASE=1 TILES=1 SOUND=1 USE_HOME_DIR=1
    fi
    sleep 5
  fi
}

function install_cataclysm_binary() {
  if [ "$arch" = 'x86_64' ]
  then
    wget -nc -q http://dev.narc.ro/cataclysm/jenkins-latest/Linux_x64/$1/
    installable=$(cat index.html | awk -F'"' '{print $6}' | grep -E "tar.gz")
    rm ./index.html
    while true
    do
      ps3="What version would you like to install?: "
      clear
      echo "Install Menu"
      select install in $installable "Go Back"
      do
        case "$install" in
          cataclysm* )
            if [ "$ver" = 'Ncurses' ]
            then
              echo "Installing needed dependencies"
              if [ "$os" = 'Debian' ]
              then
                sudo apt-get update && sudo apt-get install -y astyle libglib2.0-0 ncurses-base
            elif [ "$os" = 'Arch' ]
              then
                sudo pacman -Syy && sudo pacman -S --needed astyle glib2 ncurses
                sudo ln -s /usr/lib/libncursesw.so.6.1 /usr/lib/libncursesw.so.5
                sudo ln -s /usr/lib/libtinfo.so.6 /usr/lib/libtinfo.so.5
            elif [ "$os" = 'RPM-DNF' ]
              then
                sudo dnf install astyle.$arch glib2.$arch ncurses.$arch
                #elif [ "$os" = 'RPM-YAST']
                #then
            elif [ "$os" = 'RPM-YUM' ]
              then
                sudo yum install astyle.$arch glib2.$arch ncurses.$arch
              fi
          elif [ "$ver" = 'Tiles' ]
            then
              echo "Installing needed dependencies"
              if [ "$os" = 'Debian' ]
              then
                sudo apt-get update && sudo apt-get install -y astyle libglib2.0-0 ncurses-base
            elif [ "$os" = 'Arch' ]
              then
                sudo pacman -Syy && sudo pacman -S --needed sdl2_mixer sdl_ttf sdl2_image sdl2
            elif [ "$os" = 'RPM-DNF' ]
              then
                sudo dnf install astyle.$arch glib2.$arch ncurses.$arch
                #elif [ "$os" = 'RPM-YAST']
                #then
            elif [ "$os" = 'RPM-YUM' ]
              then
                sudo yum install astyle.$arch glib2.$arch ncurses.$arch
              fi
            fi
            wget -nc -q http://dev.narc.ro/cataclysm/jenkins-latest/Linux_x64/$1/$install
            move=$(tar -tf $install | head -n 1)
            tar -xvzf $install
            rm $install
            mv $move cataclysm-dda/
            sleep 5
            unset $installable
            unset $install
            unset $move
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
  if [ "$ver" = 'Ncurses' ]
  then
    cd ./Cataclysm-DDA
    mkdir previous_version 2>/dev/null
    mv ./* ./previous_version 2>/dev/null
    git pull
    make clean
    make -j $threads CLANG=1 CCACHE=1 LTO=1 LOCALIZE=0 RELEASE=1 USE_HOME_DIR=1
elif [ "$ver" = 'Tiles' ]
  then
    cd ./Cataclysm-DDA
    mkdir previous_version 2>/dev/null
    mv ./* ./previous_version 2>/dev/null
    git pull
    make clean
    make -j $threads CLANG=1 CCACHE=1 LTO=1 LOCALIZE=0 RELEASE=1 TILES=1 SOUND=1 USE_HOME_DIR=1
  fi
}

function update_cataclysm_binary() {
  cd ./cataclysmdda
  mkdir previous_version 2>/dev/null
  mv ./* ./previous_version 2>/dev/null
  cd ..
  install_cataclysm_binary $ver
  cd ./cataclysmdda
  for i in "${rollback[@]}"
  do
    cp -r ./previous_version/$i ./
  done
}

if [ $# = 0 ]
then
  while true
  do
    ps3="What would you like to do?: "
    clear
    echo "Main Menu"
    select question in "Cataclysm" "Backups" "Mods" "Tilesets" "Soundpacks" "Settings" "Update Launcher" "Quit"
    do
      case "$question" in
        "Cataclysm")
          while true
          do
            ps3="What would you like to do?: "
            clear
            echo "Cataclysm Menu"
            select question in "Install Cataclysm" "Compile Cataclysm" "Update Cataclysm" "Launch Cataclysm" "Go Back"
            do
              case "$question" in
                "Install Cataclysm")
                  while true
                  do
                    ps3="What version of the game would you like to install?: "
                    clear
                    echo "Install Menu"
                    select ver in "Ncurses" "Tiles" "Go Back"
                    do
                      case "$ver" in
                        "Ncurses")
                          if ! grep -q "^ver=" ./config.sh
                          then
                            echo "ver=$ver" | tee -a ./config.sh
                            source ./config.sh
                          fi
                          if [[ $(cat ./config.sh | grep "^ver=$ver") != ver=* ]]
                          then
                            sed -i "s|^ver=.*|ver=$ver|g" ./config.sh
                            source ./config.sh
                          fi
                          install_cataclysm_binary Curses
                          if ! grep -q "^install=" ./config.sh
                          then
                            echo "install=Binary" | tee -a ./config.sh
                            source ./config.sh
                          fi
                          if [[ $(cat ./config.sh | grep "^install=Binary") != install=* ]]
                          then
                            sed -i "s|^install=.*|install=Binary|g" ./config.sh
                            source ./config.sh
                          fi
                          clear
                          break
                          ;;
                        "Tiles")
                          if ! grep -q "^ver=" ./config.sh
                          then
                            echo "ver=$ver" | tee -a ./config.sh
                            source ./config.sh
                          fi
                          if [[ $(cat ./config.sh | grep "^ver=$ver") != ver=* ]]
                          then
                            sed -i "s|^ver=.*|ver=$ver|g" ./config.sh
                            source ./config.sh
                          fi
                          install_cataclysm_binary Tiles
                          if ! grep -q "^install=" ./config.sh
                          then
                            echo "install=Binary" | tee -a ./config.sh
                            source ./config.sh
                          fi
                          if [[ $(cat ./config.sh | grep "^install=Binary") != install=* ]]
                          then
                            sed -i "s|^install=.*|install=Binary|g" ./config.sh
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
                    ps3="What version of the game would you like to compile?: "
                    clear
                    echo "Compile Menu"
                    select ver in "Ncurses" "Tiles" "Go Back"
                    do
                      case "$ver" in
                        "Ncurses")
                          if ! grep -q "^ver=" ./config.sh
                          then
                            echo "ver=$ver" | tee -a ./config.sh
                            source ./config.sh
                          fi
                          if [[ $(cat ./config.sh | grep "^ver=$ver") != ver=* ]]
                          then
                            sed -i "s|^ver=.*|ver=$ver|g" ./config.sh
                            source ./config.sh
                          fi
                          install_cataclysm_compile Ncurses
                          if ! grep -q "^install=" ./config.sh
                          then
                            echo "install=Compile" | tee -a ./config.sh
                            source ./config.sh
                          fi
                          if [[ $(cat ./config.sh | grep "^install=Compile") != install=* ]]
                          then
                            sed -i "s|^install=.*|install=Compile|g" ./config.sh
                            source ./config.sh
                          fi
                          break
                          ;;
                        "Tiles")
                          if ! grep -q "^ver=" ./config.sh
                          then
                            echo "ver=$ver" | tee -a ./config.sh
                            source ./config.sh
                          fi
                          if [[ $(cat ./config.sh | grep "^ver=$ver") != ver=* ]]
                          then
                            sed -i "s|^ver=.*|ver=$ver|g" ./config.sh
                            source ./config.sh
                          fi
                          install_cataclysm_compile Tiles
                          if ! grep -q "^install=" ./config.sh
                          then
                            echo "install=Compile" | tee -a ./config.sh
                            source ./config.sh
                          fi
                          if [[ $(cat ./config.sh | grep "^install=Compile") != install=* ]]
                          then
                            sed -i "s|^install=.*|install=Compile|g" ./config.sh
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
                  if [ "$install" = 'Binary' ]
                  then
                    update_cataclysm_binary
                  elif [ "$install" = 'Compile' ]
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
  #   positional=()
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
  #     install=$2
  #     shift # past argument
  #     shift # past value
  #     ;;
  #     -v|--version)
  #     ver="$2"
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
  #     positional+=("$1") # save it in an array for later
  #     shift # past argument
  #     ;;
  # esac
  # done
  # set -- "${positional[@]}" # restore positional parameters
  #then
fi

unset arch
unset install
unset installable
unset latest
unset move
unset os
unset ps3
unset question
unset rollback
unset threads
unset update
unset ver
unset version
