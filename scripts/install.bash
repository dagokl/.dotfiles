#!/bin/bash

. scripts/install_utils.bash
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

ask_yes_no "Install Starship? [Y/n]" "y"
install_starship=$?

ask_yes_no "Install Kitty? [Y/n]" "y"
install_kitty=$?

ask_yes_no "Make Kitty default terminal? [Y/n]" "y"
make_kitty_default=$?


sudo apt update -y
sudo apt upgrade -y
sudo apt install -y \
    curl \
    git \
    htop \
    python3-pip \
    python3-venv \
    vlc \
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

        echo deb "[arch=amd64] https://regolith-desktop.org/release-ubuntu-focal-amd64 focal main" | \
        sudo tee /etc/apt/sources.list.d/regolith.list

        sudo apt update
        sudo apt install -y regolith-desktop regolith-compositor-picom-glx i3xrocks-battery
        sudo apt upgrade -y
    elif [[ $distro == "Ubuntu 22.04" ]]; then
        wget -qO - https://regolith-desktop.org/regolith.key | \
        gpg --dearmor | sudo tee /usr/share/keyrings/regolith-archive-keyring.gpg > /dev/null

        echo deb "[arch=amd64 signed-by=/usr/share/keyrings/regolith-archive-keyring.gpg] \
        https://regolith-desktop.org/release-ubuntu-jammy-amd64 jammy main" | \
        sudo tee /etc/apt/sources.list.d/regolith.list

        sudo apt update
        sudo apt install -y regolith-desktop regolith-compositor-picom-glx i3xrocks-battery
        sudo apt upgrade -y
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


# Starship
if [[ $install_starship -eq true ]]; then
    # TODO auto yes for shell script
    curl -sS https://starship.rs/install.sh | sh
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
