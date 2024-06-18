#!/bin/env bash

#### OpenBangla Keyboard Installation Script by ####
#### Js Bro ( https://github.com/me-js-bro ) ####

# color defination
red="\e[1;31m"
green="\e[1;32m"
yellow="\e[1;33m"
blue="\e[1;34m"
magenta="\e[1;1;35m"
cyan="\e[1;36m"
orange="\x1b[38;5;214m"
end="\e[1;0m"

# initial texts
attention="[${orange} ATTENTION ${end}]"
action="[${green} ACTION ${end}]"
note="[${magenta} NOTE ${end}]"
done="[${cyan} DONE ${end}]"
ask="[${orange} QUESTION ${end}]"
error="[${red} ERROR ${end}]"

display_text() {
    cat << "EOF"
     __        __    _ _         _         ____              _                   
     \ \      / / __(_) |_ ___  (_)_ __   | __ )  __ _  __ _| | __ _             
      \ \ /\ / / '__| | __/ _ \ | | '_ \  |  _ \ / _` |/ _` | |/ _` |            
       \ V  V /| |  | | ||  __/ | | | | | | |_) | (_| | (_| | | (_| |  _   _   _ 
        \_/\_/ |_|  |_|\__\___| |_|_| |_| |____/ \__,_|\__, |_|\__,_| (_) (_) (_)
                                                       |___/                          
   
EOF
}

clear && display_text
printf " \n \n"


###------ Startup ------###

# finding the presend directory and log file
present_dir=`pwd`
cache_dir="$present_dir/.cache"
distro_cache="$cache_dir/distro"
if [[ -f "$distro_cache" ]]; then
    source "$distro_cache"
fi

# log directory
log_dir="$present_dir/Logs"
log="$log_dir"/write-bangla.log
mkdir -p "$log_dir"
if [[ ! -f "$log" ]]; then
    touch "$log"
fi

# install required packages
printf "${attention} - Installing necessary packages in your ${distro} \n"
if [[ "$distro" == "arch" ]]; then
    sudo pacman -S --noconfirm base-devel rust cmake qt5-base libibus zstd fcitx5 fcitx5-configtool fcitx5-qt fcitx5-gtk git
elif [[ "$distro" == "fedora" ]]; then
    sudo dnf install -y @buildsys-build rust cargo cmake qt5-qtdeclarative-devel ibus-devel libzstd-devel git fcitx5 fcitx5-configtool fcitx5-devel fcitx5-qt5
elif [[ "$distro" = "opensuse" ]]; then
    sudo zypper in -y libQt5Core-devel libQt5Widgets-devel libQt5Network-devel libzstd-devel libzstd1 cmake make ninja rust ibus-devel ibus clang gcc patterns-devel-base-devel_basis git fcitx5-devel fcitx5 fcitx5-configtool
elif [[ "$distro" = "void" ]]; then
	sudo xbps-install base-devel make cmake rust cargo qt5-declarative-devel libzstd-devel qt5-devel cmake-devel git fcitx5 libfcitx5-devel fcitx5-configtool
fi

printf "${action} - Now building ${yellow}Openbangla Keyboard ${end}...\n"

git clone --recursive https://github.com/asifakonjee/openbangla-fcitx5.git "$cache_dir/openbangla-fcitx5" 2>&1 | tee -a "$log" || { printf "${error} - Sorry, could not clone openbangla-fcitx5 repository\n" 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log"); exit 1; }
sleep 1

# Move into the cloned directory
cd "$cache_dir/openbangla-fcitx5" || { printf "${error} - Unable to change directory\n" 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log"); exit 1; }

# Create build directory
mkdir build 2>&1 | tee -a "$log" || { printf "${error} - Unable to create build directory\n" 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log"); exit 1; }

cd build || { printf "${error} - Unable to change directory\n" 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log"); exit 1; }

# Run CMake to configure the build
cmake .. 2>&1 | tee -a "$log" || { printf "${error} - CMake configuration failed\n" 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log"); exit 1; }

# Build the project
make 2>&1 | tee -a "$log" || { printf "${error} - Build failed\n" 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log"); exit 1; }

# Install the project
sudo make install 2>&1 | tee -a "$log" || { printf "${error} - Installation failed\n" 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log"); exit 1; }

if https://github.com/asifakonjee/Fonts.git "$cache_dir/Fonts" 2>&1 | tee -a "$log"; then
    mkdir -p ~/.local/share/fonts
    cp -r "$cache_dir/Bangla-Fonts" ~/.local/share/fonts/
    sudo fc-cache -fv 2>&1 | tee -a "$log"
fi
