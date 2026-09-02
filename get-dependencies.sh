#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    base-devel        \
    cmake             \
    audacious         \
    audacious-plugins \
    fluidsynth        \
    lxqt-qtplugin     \
    kvantum           \
    pipewire-audio    \
    pipewire-jack     \
    qt6ct

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano ffmpeg-mini


# Build and install Audacious Discord RPC plugin
echo "Building Audacious Discord RPC plugin..."
git clone --depth 1 https://github.com/onegen-dev/audacious-discord-rpc.git /tmp/audacious-discord-rpc

# Patch CMakeLists.txt: replace unconditional x86 flags with arch-conditional ones
cd /tmp/audacious-discord-rpc
if [ "$ARCH" = "aarch64" ]; then
    sed -i '/-march=x86-64-v2/d' CMakeLists.txt
    sed -i '/-mtune=generic/d' CMakeLists.txt
    sed -i '/-fcf-protection=full/d' CMakeLists.txt
fi
cd

cmake -S /tmp/audacious-discord-rpc -B /tmp/audacious-discord-rpc/build -DCMAKE_BUILD_TYPE=Release
cmake --build /tmp/audacious-discord-rpc/build -j$(nproc)
install -Dm755 /tmp/audacious-discord-rpc/build/discord-rpc.so /usr/lib/audacious/General/discord-rpc.so