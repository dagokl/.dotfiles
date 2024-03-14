#!/bin/bash

script_dir="$(dirname "$0")"
. "$script_dir"/install_utils.bash
sudo -v

# distro will have value like "Ubuntu 20.04" or "Ubuntu 22.04"
distro=$(lsb_release -isr)
distro=${distro//$'\n'/ }
echo "Detected distro: $distro"

ask_yes_no "Install fonts? [Y/n]" "y"
install_fonts=$?

ask_yes_no "Remap caps lock to escape? [Y/n]" "y"
remap_caps_lock=$?

ask_yes_no "Install Regolith? [Y/n]" "y"
install_regolith=$?

ask_yes_no "Install Helix? [Y/n]" "y"
install_helix=$?

ask_yes_no "Install Pyright and Ruff LSPs? [Y/n]" "y"
install_python_lsps=$?

ask_yes_no "Install Bash LSP? [Y/n]" "y"
install_bash_lsp=$?

ask_yes_no "Install Starship? [Y/n]" "y"
install_starship=$?

ask_yes_no "Install Kitty? [Y/n]" "y"
install_kitty=$?

ask_yes_no "Make Kitty default terminal? [Y/n]" "y"
make_kitty_default=$?

ask_yes_no "Install Lazygit? [Y/n]" "y"
install_lazygit=$?

ask_yes_no "Install misc usefull packages? [Y/n]" "y"
install_misc_packages=$?

ask_yes_no "Add deadsnakes PPA? [Y/n]" "y"
add_deadsnakes=$?


# Some packages needed for rest of setup
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y \
    curl \
    wget


# Fonts
if [[ $install_fonts -eq true ]]; then
    sudo apt install -y \
        fonts-firacode \
        fontconfig
    sudo cp -r fonts/* /usr/share/fonts/
    sudo fc-cache -f -v
fi


# Regolith
if [[ $install_regolith -eq true ]]; then    
    if [[ $distro == "Ubuntu 20.04" ]]; then
        wget -qO - https://regolith-desktop.org/regolith.key | sudo apt-key add -

        echo deb "[arch=amd64] https://regolith-desktop.org/release-3_1-ubuntu-focal-amd64 focal main" | \
        sudo tee /etc/apt/sources.list.d/regolith.list

        sudo apt update
        sudo apt install -y regolith-desktop regolith-session-flashback regolith-look-lascaille i3xrocks-battery
    elif [[ $distro == "Ubuntu 22.04" ]]; then
        wget -qO - https://regolith-desktop.org/regolith.key | \
        gpg --dearmor | sudo tee /usr/share/keyrings/regolith-archive-keyring.gpg > /dev/null
        
        echo deb "[arch=amd64 signed-by=/usr/share/keyrings/regolith-archive-keyring.gpg] \
        https://regolith-desktop.org/release-3_1-ubuntu-jammy-amd64 jammy main" | \
        sudo tee /etc/apt/sources.list.d/regolith.list

        sudo apt update
        sudo apt install regolith-desktop regolith-session-flashback regolith-look-lascaille i3xrocks-battery
    else
        echo "Regolith install only works on Ubuntu 20.04 and 22.04"
    fi
fi


# Helix
if [[ $install_helix -eq true ]]; then
    sudo add-apt-repository -y ppa:maveonair/helix-editor
    sudo apt update
    sudo apt install -y helix
fi


# Python Language Servers
if [[ $install_python_lsps -eq true ]]; then
    sudo apt install python3-pip
    pip install pyright ruff-lsp
fi


# Bash Language Server
if [[ $install_bash_lsp -eq true ]]; then
    sudo snap install bash-language-server --classic
fi


# Starship
if [[ $install_starship -eq true ]]; then
    curl -sS -o install_starship.sh https://starship.rs/install.sh
    chmod +x ./install_starship.sh
    sh ./install_starship.sh -y
    rm ./install_starship.sh
    echo 'eval "$(starship init bash)"' >> ~/.bashrc
fi


# Kitty
if [[ $install_kitty -eq true ]]; then
    # sudo apt install -y kitty
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

    # Create symbolic links to add kitty and kitten to PATH (assuming ~/.local/bin is in
    # your system-wide PATH)
    ln -sf ~/.local/kitty.app/bin/kitty ~/.local/kitty.app/bin/kitten ~/.local/bin/
    # Place the kitty.desktop file somewhere it can be found by the OS
    cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
    # If you want to open text files and images in kitty via your file manager also add the kitty-open.desktop file
    cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/
    # Update the paths to the kitty and its icon in the kitty.desktop file(s)
    sed -i "s|Icon=kitty|Icon=/home/$USER/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
    sed -i "s|Exec=kitty|Exec=/home/$USER/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop
fi


if [[ $make_kitty_default -eq true ]]; then
    sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator ~/.local/kitty.app/bin/kitty 50
    # sudo update-alternatives --config x-terminal-emulator
fi


if [[ $install_misc_packages -eq true ]]; then
    sudo apt update -y
    sudo apt upgrade -y
    sudo apt install -y \
        htop \
        python3-pip \
        python3-venv \
        python3-dev \
        vlc
fi


if [[ $add_deadsnakes -eq true ]]; then
    sudo apt install software-properties-common
    sudo add-apt-repository ppa:deadsnakes/ppa
fi


if [[ $install_lazygit -eq true ]]; then
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin
    rm -f lazygit.tar.gz lazygit
fi
