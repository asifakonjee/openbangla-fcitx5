```bash
#!/usr/bin/env bash

#### OpenBangla Keyboard (Develop Branch) for fcitx5 Installation Script ####
#### ( https://github.com/asifakonjee ) ####

# color defination
red="\e[1;31m"
green="\e[1;32m"
yellow="\e[1;33m"
blue="\e[1;34m"
magenta="\e[1;1;35m"
cyan="\e[1;36m"
orange="\x1b[38;5;214m"
end="\e[1;0m"

attention="[${orange} ATTENTION ${end}]"
action="[${green} ACTION ${end}]"
note="[${magenta} NOTE ${end}]"
done="[${cyan} DONE ${end}]"
ask="[${orange} QUESTION ${end}]"
error="[${red} ERROR ${end}]"

display_text() {
    cat << "EOF"
  ____                   ___                    __
 / __ \ ___  ___  ___   / _ ) ___ _ ___  ___ _ / /___ _
/ /_/ // _ \/ -_)/ _ \ / _  |/ _ `// _ \/ _ `// // _ `/
\____// .__/\__//_//_//____/ \_,_//_//_/\_, //_/ \_,_/
     /_/                               /___/
EOF
}

clear && display_text
printf "\n\n"

present_dir="$(dirname "$(realpath "$0")")"
cache_dir="$present_dir/.cache"
log="$present_dir/Install.log"

mkdir -p "$cache_dir"
touch "$log"

# Detect package manager
if command -v pacman &> /dev/null; then
    pkg="pacman"
elif command -v dnf &> /dev/null; then
    pkg="dnf"
elif command -v zypper &> /dev/null; then
    pkg="zypper"
elif command -v xbps-install &> /dev/null; then
    pkg="xbps-install"
elif command -v apt &> /dev/null; then
    pkg="apt"
else
    printf "${error}\n! No supported package manager found!\n"
    exit 1
fi

printf "${attention}\n!! Installing necessary packages using ${pkg}\n"

case "$pkg" in
    pacman)
        sudo pacman -S --noconfirm base-devel rust cmake qt5-base zstd fcitx5 fcitx5-configtool fcitx5-qt fcitx5-gtk git
        ;;
    dnf)
        sudo dnf install -y @development-tools rust cargo cmake qt5-qtdeclarative-devel libzstd-devel fcitx5 fcitx5-configtool fcitx5-devel fcitx5-qt5 git
        ;;
    zypper)
        sudo zypper in -y libQt5Core-devel libQt5Widgets-devel libQt5Network-devel libzstd-devel cmake make ninja rust gcc fcitx5-devel fcitx5 fcitx5-configtool git
        ;;
    xbps-install)
        sudo xbps-install -y base-devel cmake rust cargo qt5-devel libzstd-devel fcitx5 libfcitx5-devel fcitx5-configtool git
        ;;
    apt)
        sudo apt update
        sudo apt install -y build-essential curl cmake qtbase5-dev qtbase5-dev-tools libzstd-dev libfcitx5core-dev fcitx5 fcitx5-config-qt git

        printf "${note}\n* Installing Rust via rustup...\n"

        if ! command -v rustup &>/dev/null; then
            curl https://sh.rustup.rs -sSf | sh -s -- -y
        fi
        ;;
esac

# Load Rust environment
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi
export PATH="$HOME/.cargo/bin:$PATH"

printf "${note}\n* Rust: $(rustc --version 2>/dev/null)\n"
printf "${note}\n* CMake: $(cmake --version | head -n1)\n"

printf "${action}\n==> Building OpenBangla Keyboard...\n"

rm -rf "$cache_dir/openbangla-keyboard"

git clone --recursive https://github.com/asifakonjee/openbangla-fcitx5.git "$cache_dir/openbangla-keyboard" 2>&1 | tee -a "$log" || exit 1

cd "$cache_dir/openbangla-keyboard" || exit 1

mkdir -p build && cd build || exit 1

# CMake with Rust support FIX
cmake .. \
  -DCMAKE_INSTALL_PREFIX="/usr" \
  -DENABLE_FCITX=ON \
  -DCMAKE_EXPERIMENTAL_RUST=ON \
  -DCMAKE_RUST_COMPILER="$(which rustc)" \
  2>&1 | tee -a "$log" || {
    printf "${error}\n! CMake configuration failed\n"
    exit 1
}

make -j$(nproc) 2>&1 | tee -a "$log" || {
    printf "${error}\n! Build failed\n"
    exit 1
}

sudo make install 2>&1 | tee -a "$log" || {
    printf "${error}\n! Installation failed\n"
    exit 1
}

printf "${done}\n==> Installation completed successfully!\n"

# Install fonts
printf "\n${attention} Installing Bangla fonts...\n"

if git clone --depth=1 https://github.com/asifakonjee/bangla-fonts.git "$cache_dir/Fonts" 2>&1 | tee -a "$log"; then
    mkdir -p ~/.local/share/fonts
    cp -r "$cache_dir/Fonts"/* ~/.local/share/fonts/
    fc-cache -fv 2>&1 | tee -a "$log"
    printf "${done}\n==> Fonts installed successfully!\n"
else
    printf "${error} Could not install fonts.\n"
fi

exit 0
```
