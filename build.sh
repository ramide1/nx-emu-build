#!/bin/bash

rm ~/x
echo "Installing deps..."
sudo pacman -Syu --needed --noconfirm base-devel cmake git glslang libzip mbedtls ninja zip unzip && echo "deps installed correctly" || echo "error installing deps"
echo "Select emu:"
echo "1) Citron"
echo "2) Torzu"
read -rp "Choose an option [1-2]: " emu_version
if [ "$emu_version" != "1" ] && [ "$emu_version" != "2" ]; then
    echo "Invalid option. Exiting."
    exit 1
fi
case "$emu_version" in
    1)
        emu_directory="Citron"
        echo "Cloning Citron..."
        cd ~/
        git clone --recursive https://git.citron-emu.org/Citron/Citron.git && echo "Citron cloned correctly" || echo "error cloning Citron"
        ;;
    2)
        emu_directory="torzu"
        echo "Cloning Torzu..."
        cd ~/
        git clone --depth 1 https://notabug.org/litucks/torzu.git && echo "Torzu cloned correctly" || echo "error cloning Torzu"
        cd torzu
        git submodule update --init --recursive && echo "submodules updated correctly" || echo "error updating submodules"
        cd ~/
        ;;
esac
echo "Select platform:"
echo "1) Linux"
echo "2) Android"
read -rp "Choose an option [1-2]: " emu_platform
if [ "$emu_platform" != "1" ] && [ "$emu_platform" != "2" ]; then
    echo "Invalid option. Exiting."
    rm -rf "$emu_directory"
    exit 1
fi
case "$emu_platform" in
    1)
        case "$emu_version" in
            1)
                echo "Installing qt6..."
                sudo pacman -Syu --needed --noconfirm qt6 && echo "qt6 installed correctly" || echo "error installing qt6"
                rm -rf citron-nightly-*-x86_64.AppImage
                ;;
            2)
                echo "Installing qt5..."
                sudo pacman -Syu --needed --noconfirm qt5 && echo "qt5 installed correctly" || echo "error installing qt5"
                rm -rf torzu
                ;;
        esac
        cd "$emu_directory"
        mkdir build && cd build
        echo "Building cmake..."
        case "$emu_version" in
            1)
                cmake .. -GNinja \
                    -DCITRON_ENABLE_LTO=ON \
                    -DCITRON_USE_BUNDLED_VCPKG=ON \
                    -DCITRON_TESTS=OFF \
                    -DCITRON_USE_LLVM_DEMANGLE=OFF \
                    -DCMAKE_INSTALL_PREFIX=/usr \
                    -DCMAKE_CXX_FLAGS="-march=native -mtune=native -Wno-error" \
                    -DCMAKE_C_FLAGS="-march=native -mtune=native" \
                    -DUSE_DISCORD_PRESENCE=OFF \
                    -DBUNDLE_SPEEX=ON \
                    -DCMAKE_SYSTEM_PROCESSOR=x86_64 \
                    -DCMAKE_BUILD_TYPE=Release && echo "cmake builded correctly" || echo "error building cmake"
                ;;
            2)
                cmake .. -GNinja -DYUZU_USE_BUNDLED_VCPKG=ON -DYUZU_TESTS=OFF && echo "cmake builded correctly" || echo "error building cmake"
                ;;
        esac
        echo "Building bin..."
        ninja && echo "bin builded correctly" || echo "error building bin"
        case "$emu_version" in
            1)
                echo "Building appimage..."
                cd .. && ./appimage-builder.sh citron build && echo "appimage builded correctly" || echo "error building appimage"
                chmod +x build/deploy-linux/citron-nightly-*-x86_64.AppImage && echo "permissions updated correctly" || echo "error updating permissions"
                mv build/deploy-linux/citron-nightly-*-x86_64.AppImage ~/
                ;;
            2)
                mv bin/yuzu ~/torzu
                ;;
        esac
        ;;
    2)
        echo "Installing wget..."
        sudo pacman -Syu --needed --noconfirm wget && echo "wget installed correctly" || echo "error installing wget"
        case "$emu_version" in
            1)
                rm -rf Citron-*-mainlineRelease.apk
                ;;
            2)
                rm -rf torzu-mainline-release.apk
                ;;
        esac
        wget https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.6%2B7/OpenJDK21U-jdk_x64_linux_hotspot_21.0.6_7.tar.gz -O OpenJDK.tar.gz && echo "OpenJDK downloaded correctly" || echo "error downloading OpenJDK"
        tar xzf OpenJDK.tar.gz && echo "OpenJDK extracted correctly" || echo "error extracting OpenJDK"
        rm OpenJDK.tar.gz
        wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O commandlinetools.zip && echo "Android SDK downloaded correctly" || echo "error downloading Android SDK"
        mkdir -p ~/Android/Sdk/cmdline-tools
        unzip commandlinetools.zip -d ~/Android/Sdk/cmdline-tools && echo "Android SDK extracted correctly" || echo "error extracting Android SDK"
        rm commandlinetools.zip
        mv ~/Android/Sdk/cmdline-tools/cmdline-tools ~/Android/Sdk/cmdline-tools/latest
        export JAVA_HOME=$HOME/jdk-21.0.6+7
        export PATH=$PATH:$JAVA_HOME/bin
        export ANDROID_SDK_ROOT=$HOME/Android/Sdk
        export PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin
        export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools
        if [ "$emu_version" == "1" ]; then
            sed -i 's|set(VCPKG_HOST_TRIPLET "x64-windows")|set(VCPKG_HOST_TRIPLET "x64-linux")|g' Citron/CMakeLists.txt
        fi
        cd "$emu_directory/src/android"
        echo "Building apk..."
        yes | sdkmanager --licenses
        if [ "$emu_version" == "1" ]; then
            sdkmanager "cmake;3.31.5"
        fi
        ./gradlew assembleRelease && echo "apk builded correctly" || echo "error building apk"
        rm -rf ~/Android
        rm -rf ~/jdk-21.0.6+7
        case "$emu_version" in
            1)
                mv app/build/outputs/apk/mainline/release/Citron-*-mainlineRelease.apk ~/
                ;;
            2)
                mv app/build/outputs/apk/mainline/release/app-mainline-release.apk ~/torzu-mainline-release.apk
                ;;
        esac
        ;;
esac
cd ~/
rm -rf "$emu_directory"
echo "Build success. You can now copy files"
