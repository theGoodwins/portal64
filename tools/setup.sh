#!/bin/bash

# Add repository to system sources
add_repo() {
    echo "deb [trusted=yes] $1" | sudo tee /etc/apt/sources.list.d/$2.list
}

# Install packages
install_packages() {
    sudo apt install -y $@
}

# Clone and build a repository if it doesn't exist
clone_and_build() {
    local repo=$1
    local dir=$2

    if [ ! -d "$dir" ]; then
        git clone "$repo" && \
        cd "$dir" && \
        chmod +x ./build.sh && \
        ./build.sh
    else
        echo "$dir already exists. Skipping clone and build."
    fi
}

# Repositories
N64SDK_REPO="https://crashoveride95.github.io/apt/ ./"
LAMBERTJAMESD_REPO="https://lambertjamesd.github.io/apt/ ./"

# Add repositories
add_repo "$N64SDK_REPO" "n64sdk"
add_repo "$LAMBERTJAMESD_REPO" "lambertjamesd"

# Update system package lists and add architecture
sudo dpkg --add-architecture i386
sudo apt update

# Install various packages
COMMON_PACKAGES="binutils-mips-n64 gcc-mips-n64 git imagemagick liblua5.4-0 liblua5.4-dev \
                 libnustd lua5.4 make makemask mpg123 newlib-mips-n64 nodejs n64sdk \
                 root-compatibility-environment sfz2n64 sox unzip vtf2png build-essential \
                 libpng-dev pipx"
WSL_PACKAGES="libxfixes3 libxi6 libxkbcommon0 libxxf86vm1 libgl1-mesa-glx"

install_packages $COMMON_PACKAGES
install_packages $WSL_PACKAGES

# Install Blender and FFmpeg via snap
sudo snap install blender --channel=3.6lts/stable --classic
sudo snap install ffmpeg

# Configure environment variables
echo 'export N64_LIBGCCDIR=/opt/crashsdk/lib/gcc/mips64-elf/12.2.0' >> ~/.bashrc
echo 'export BLENDER_3_6=/snap/bin/blender' >> ~/.bashrc
echo 'export PATH=$PATH:/opt/crashsdk/bin' >> ~/.bashrc
echo 'export ROOT=/etc/n64' >> ~/.bashrc

# Set up pipx
pipx ensurepath --force
pipx install vpk

# Install GCC toolchain
GCC_TOOLCHAIN_URL="https://github.com/DragonMinded/libdragon/releases/download/toolchain-continuous-prerelease/gcc-toolchain-mips64-x86_64.deb"
wget "$GCC_TOOLCHAIN_URL" && sudo dpkg -i gcc-toolchain-mips64-x86_64.deb

# Source the updated .bashrc to apply changes needed by libdragon
source ~/.bashrc

# Clone and build libdragon
LIBDRAGON_REPO="https://github.com/DragonMinded/libdragon.git"
LIBDRAGON_DIR="libdragon"
clone_and_build "$LIBDRAGON_REPO" "$LIBDRAGON_DIR"

# Source the updated .bashrc to apply changes
source ~/.bashrc

# Final instructions
echo "Setup is almost complete. Add the files from the Portal folder to portal64/vpk"
read -p "When complete, press Enter to finish setup."
echo "Setup complete. Please restart the terminal if paths are not updated."
