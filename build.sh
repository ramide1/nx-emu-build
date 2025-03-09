#!/bin/bash

echo "Select emu:"
echo "1) Citron"
echo "2) Torzu"
read -rp "Choose an option [1-2]: " emu_version
if [ "$emu_version" != "1" ] && [ "$emu_version" != "2" ]; then
    echo "Invalid option"
    exit 1
fi
case "$emu_version" in
    1)
        emu_version="citron"
        ;;
    2)
        emu_version="torzu"
        ;;
esac
echo "Select platform:"
echo "1) Linux 💻"
echo "2) Android 📱"
read -rp "Choose an option [1-2]: " emu_platform
if [ "$emu_platform" != "1" ] && [ "$emu_platform" != "2" ]; then
    echo "Invalid option"
    exit 1
fi
case "$emu_platform" in
    1)
        emu_platform="linux"
        ;;
    2)
        emu_platform="android"
        ;;
esac
echo "⚒️Building Image...⚒️"
image_version="$emu_version"_"$emu_platform"
docker build -t ramide1/nx-emu-build:$image_version -f Dockerfile_$image_version .
docker run --rm -it -v ./outputs:/root/outputs ramide1/nx-emu-build:$image_version
docker rmi ramide1/nx-emu-build:$image_version