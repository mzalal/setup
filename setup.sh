#!/bin/bash

total_steps=11
current_step=1

function step() {
    echo -e "\e[1;34m[$current_step/$total_steps] $1\e[0m"
    current_step=$(expr $current_step + 1)
}

echo "Fully update and reboot your system before running this script."
read -p "Continue with setup? [y/N]: " continue_setup

if [[ "$continue_setup" != "y" && "$continue_setup" != "Y" ]]; then
    exit
else
    echo "Starting setup script..."
fi

step "Enable RPM Fusion repositories"
sudo dnf install -y\
    https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm\
    https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

step "Enable Flathub remote"
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

step "Enable COPR repositories"
sudo dnf copr enable wezfurlong/wezterm-nightly -y
sudo dnf copr enable zawertun/kde-kup -y

step "Add Brave Browser repository"
sudo dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo

step "Add Visual Studio Code repository"
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null

step "Install non-free media codecs"
sudo dnf swap ffmpeg-free ffmpeg -y --allowerasing
sudo dnf update @multimedia -y --setopt=\"install_weak_deps=False\" --exclude=PackageKit-gstreamer-plugin

step "Install NVM/Node.js"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
source ~/.bashrc
nvm install --lts
nvm use --lts

step "Install various packages"
sudo dnf install -y\
    neovim\
    wezterm\
    kde-kup\
    syncthing\
    keepassxc\
    lua\
    vlc\
    qbittorrent\
    thunderbird\
    calibre\
    git\
    tldr\
    btop\
    virt-manager\
    brave-browser\
    code
flatpak install -y md.obsidian.Obsidian

step "Set configuration files"
git clone https://github.com/mzalal/config
cp -r config/.git ~/.config
cp -r config/.gitignore ~/.config
cp -r config/* ~/.config

step "Generate SSH keys"
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N "" -C "PRIMARY"
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_secondary -N "" -C "SECONDARY"

step "Set Bash aliases"
echo "source ~/.config/alias.sh" >> ~/.bashrc
