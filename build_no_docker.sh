#!/bin/bash

rm build_no_docker.sh
echo "Select emu:"
echo "1) Citron"
echo "2) Torzu"
read -rp "Choose an option [1-2]: " emu_version
if [ "$emu_version" != "1" ] && [ "$emu_version" != "2" ]; then
    echo "Invalid option"
    exit 1
fi
echo "Select platform:"
echo "1) Linux 💻"
echo "2) Android 📱"
read -rp "Choose an option [1-2]: " emu_platform
if [ "$emu_platform" != "1" ] && [ "$emu_platform" != "2" ]; then
    echo "Invalid option"
    exit 1
fi
echo "⬇️Installing deps...⬇️"
sudo pacman -Syu --needed --noconfirm base-devel cmake git glslang libzip mbedtls ninja zip unzip && echo "✔️⬇️Deps installed correctly⬇️✔️" || echo "❌⬇️Error installing deps⬇️❌"
case "$emu_version" in
    1)
        emu_version="Citron"
        echo "💾Cloning $emu_version...💾"
        git clone --recursive https://git.citron-emu.org/Citron/Citron.git "$emu_version" && echo "✔️💾$emu_version cloned correctly💾✔️" || echo "❌💾Error cloning $emu_version💾❌"
        ;;
    2)
        emu_version="Torzu"
        echo "💾Cloning $emu_version...💾"
        git clone --depth 1 https://notabug.org/litucks/torzu.git "$emu_version" && echo "✔️💾$emu_version cloned correctly💾✔️" || echo "❌💾Error cloning $emu_version💾❌"
        cd "$emu_version"
        git submodule update --init --recursive && echo "✔️⬇️Submodules updated correctly⬇️✔️" || echo "❌⬇️Error updating submodules⬇️❌"
        cd ..
        ;;
esac
case "$emu_platform" in
    1)
        case "$emu_version" in
            Citron)
                echo "⬇️Installing qt6 and sdl3...⬇️"
                sudo pacman -Syu --needed --noconfirm qt6 sdl3 && echo "✔️⬇️Qt6 and sdl3 installed correctly⬇️✔️" || echo "❌⬇️Error installing qt6 and sdl3⬇️❌"
                ;;
            Torzu)
                echo "⬇️Installing qt5 and sdl3...⬇️"
                sudo pacman -Syu --needed --noconfirm qt5 sdl3 && echo "✔️⬇️Qt5 and sdl3 installed correctly⬇️✔️" || echo "❌⬇️Error installing qt5 and sdl3⬇️❌"
                ;;
        esac
        rm -rf "$emu_version"-nightly-*-x86_64.AppImage
        cd "$emu_version"
        mkdir build && cd build
        echo "⚒️Building cmake...⚒️"
        case "$emu_version" in
            Citron)
                cmake .. -GNinja \
                    -DCITRON_ENABLE_LTO=ON \
                    -DCITRON_USE_BUNDLED_VCPKG=ON \
                    -DCITRON_TESTS=OFF \
                    -DCITRON_USE_LLVM_DEMANGLE=OFF \
                    -DCMAKE_INSTALL_PREFIX=/usr \
                    -DUSE_DISCORD_PRESENCE=OFF \
                    -DBUNDLE_SPEEX=ON \
                    -DCMAKE_BUILD_TYPE=Release && echo "cmake builded correctly" || echo "error building cmake"
                ;;
            Torzu)
                cmake .. -GNinja \
                    -DYUZU_ENABLE_LTO=ON \
                    -DYUZU_USE_BUNDLED_VCPKG=ON \
                    -DYUZU_TESTS=OFF \
                    -DYUZU_USE_LLVM_DEMANGLE=OFF \
                    -DCMAKE_INSTALL_PREFIX=/usr \
                    -DUSE_DISCORD_PRESENCE=OFF \
                    -DBUNDLE_SPEEX=ON \
                    -DCMAKE_BUILD_TYPE=Release && echo "cmake builded correctly" || echo "error building cmake"
                ;;
        esac
        echo "⚒️Building bin...⚒️"
        ninja && echo "✔️⚒️Bin builded correctly⚒️✔️" || echo "❌⚒️Error building bin⚒️❌"
        echo "⚒️Building appimage...⚒️"
        BUILD_DIR=$(realpath .)
        DEPLOY_LINUX_DIR="$BUILD_DIR/deploy-linux"
        DEPLOY_LINUX_APPDIR="$DEPLOY_LINUX_DIR/AppDir"
        mkdir -p "$DEPLOY_LINUX_APPDIR"
        DESTDIR="$DEPLOY_LINUX_APPDIR" ninja install
        mkdir -p "$DEPLOY_LINUX_APPDIR/usr/lib"
        cp /usr/lib/libSDL3.so* "$DEPLOY_LINUX_APPDIR/usr/lib"
        cd "$DEPLOY_LINUX_DIR"
        rm -rf "$DEPLOY_LINUX_APPDIR/usr/bin/yuzu-cmd"
        curl -fsSLo ./linuxdeploy "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage"
        chmod +x ./linuxdeploy
        curl -fsSLo ./linuxdeploy-plugin-qt "https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage"
        chmod +x ./linuxdeploy-plugin-qt
        curl -fsSLo ./linuxdeploy-plugin-checkrt.sh https://github.com/darealshinji/linuxdeploy-plugin-checkrt/releases/download/continuous/linuxdeploy-plugin-checkrt.sh
        chmod +x ./linuxdeploy-plugin-checkrt.sh
        export QT_QPA_PLATFORM="wayland;xcb"
        export EXTRA_PLATFORM_PLUGINS="libqwayland-egl.so;libqwayland-generic.so;libqxcb.so"
        case "$emu_version" in
            Citron)
                export EXTRA_QT_PLUGINS="svg;wayland-decoration-client;wayland-graphics-integration-client;wayland-shell-integration;waylandcompositor;xcb-gl-integration;platformthemes/libqt6ct.so"
                export QMAKE="/usr/bin/qmake6"
                export QT_SELECT=6
                ;;
            Torzu)
                export EXTRA_QT_PLUGINS="svg;wayland-decoration-client;wayland-graphics-integration-client;wayland-shell-integration;waylandcompositor;xcb-gl-integration;platformthemes/libqt5ct.so"
                export QMAKE="/usr/bin/qmake"
                export QT_SELECT=5
                ;;
        esac
        NO_STRIP=1 APPIMAGE_EXTRACT_AND_RUN=1 ./linuxdeploy --appdir ./AppDir --plugin qt --plugin checkrt
        rm -fv ./AppDir/usr/lib/libwayland-client.so*
        rm -fv ./AppDir/usr/lib/libvulkan.so*
        rm -rf ./linuxdeploy-squashfs-root
        ./linuxdeploy --appimage-extract
        mv -v ./squashfs-root/ ./linuxdeploy-squashfs-root/
        ./linuxdeploy-squashfs-root/plugins/linuxdeploy-plugin-appimage/usr/bin/appimagetool ./AppDir -g && echo "✔️⚒️Appimage builded correctly⚒️✔️" || echo "❌⚒️Error building appimage⚒️❌"
        COMM_COUNT=$(git rev-list --count HEAD)
        COMM_HASH=$(git rev-parse --short=9 HEAD)
        BUILD_DATE=$(date +"%Y%m%d")
        APPIMAGE_NAME="$emu_version-nightly-$BUILD_DATE-$COMM_COUNT-$COMM_HASH-x86_64.AppImage"
        LATEST_APPIMAGE=$(ls -1t "$emu_version"*.AppImage | head -n 1)
        if [[ -z "${LATEST_APPIMAGE}" ]]; then
            >&2 echo "Error: No AppImage found for $emu_version"
            exit 1
        fi
        mv -v "$LATEST_APPIMAGE" "$APPIMAGE_NAME"
        FILESIZE=$(stat -c %s "./${APPIMAGE_NAME}")
        SHA256SUM=$(sha256sum "./${APPIMAGE_NAME}" | awk '{ print $1 }')
        echo "$APPIMAGE_NAME"
        echo "${SHA256SUM};${FILESIZE}B"
        chmod +x "$APPIMAGE_NAME" && echo "✔️Permissions updated correctly✔️" || echo "❌Error updating permissions❌"
        mv "$APPIMAGE_NAME" ../../../
        cd ../../../
        ;;
    2)
        echo "Installing wget and vulkan-headers..."
        sudo pacman -Syu --needed --noconfirm wget vulkan-headers && echo "wget and vulkan-headers installed correctly" || echo "error installing wget and vulkan-headers"
        rm -rf "$emu_version-mainlineRelease.apk"
        wget https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.6%2B7/OpenJDK21U-jdk_x64_linux_hotspot_21.0.6_7.tar.gz -O OpenJDK.tar.gz && echo "OpenJDK downloaded correctly" || echo "error downloading OpenJDK"
        tar xzf OpenJDK.tar.gz && echo "OpenJDK extracted correctly" || echo "error extracting OpenJDK"
        rm OpenJDK.tar.gz
        wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O commandlinetools.zip && echo "Android SDK downloaded correctly" || echo "error downloading Android SDK"
        mkdir -p Android/Sdk/cmdline-tools
        unzip commandlinetools.zip -d Android/Sdk/cmdline-tools && echo "Android SDK extracted correctly" || echo "error extracting Android SDK"
        rm commandlinetools.zip
        mv Android/Sdk/cmdline-tools/cmdline-tools Android/Sdk/cmdline-tools/latest
        BUILD_DIR=$(realpath .)
        export JAVA_HOME="$BUILD_DIR"/jdk-21.0.6+7
        export PATH=$PATH:$JAVA_HOME/bin
        export ANDROID_SDK_ROOT="$BUILD_DIR"/Android/Sdk
        export PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin
        export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools
        if [ "$emu_version" == "Citron" ]; then
            sed -i 's|set(VCPKG_HOST_TRIPLET "x64-windows")|set(VCPKG_HOST_TRIPLET "x64-linux")|g' "$emu_version/CMakeLists.txt"
        fi
        cd "$emu_version/src/android"
        echo "Building apk..."
        yes | sdkmanager --licenses
        ./gradlew assembleRelease && echo "apk builded correctly" || echo "error building apk"
        rm -rf "$BUILD_DIR/Android"
        rm -rf "$BUILD_DIR/jdk-21.0.6+7"
        mv app/build/outputs/apk/mainline/release/*.apk "$BUILD_DIR/$emu_version-mainlineRelease.apk"
        cd "$BUILD_DIR"
        ;;
esac
rm -rf "$emu_version"