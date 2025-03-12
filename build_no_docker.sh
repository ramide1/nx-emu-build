#!/bin/bash

rm build_no_docker.sh
echo "Select emu:"
echo "1) Citron"
echo "2) Torzu"
echo "3) Strato"
read -rp "Choose an option [1-3]: " emu_version
if [ "$emu_version" != "1" ] && [ "$emu_version" != "2" ] && [ "$emu_version" != "3" ]; then
    echo "Invalid option"
    exit 1
fi
if [ "$emu_version" != "3" ]; then
    echo "Select platform:"
    echo "1) Linux 💻"
    echo "2) Android 📱"
    read -rp "Choose an option [1-2]: " emu_platform
    if [ "$emu_platform" != "1" ] && [ "$emu_platform" != "2" ]; then
        echo "Invalid option"
        exit 1
    fi
else
	emu_platform="2"
fi
WORKING_DIR=$(realpath .)
echo "⬇️Installing deps...⬇️"
sudo pacman -Syu --needed --noconfirm base-devel cmake git glslang libzip mbedtls ninja zip unzip && echo "✔️⬇️Deps installed correctly⬇️✔️" || echo "❌⬇️Error installing deps⬇️❌"
case "$emu_version" in
    1)
        emu_version="citron"
        echo "💾Cloning Citron...💾"
        git clone --recursive https://git.citron-emu.org/Citron/Citron.git "$emu_version" && echo "✔️💾Citron cloned correctly💾✔️" || echo "❌💾Error cloning Citron💾❌"
        ;;
    2)
        emu_version="torzu"
        echo "💾Cloning Torzu...💾"
        git clone --depth 1 https://notabug.org/litucks/torzu.git "$emu_version" && echo "✔️💾Torzu cloned correctly💾✔️" || echo "❌💾Error cloning Torzu💾❌"
        cd "$emu_version"
        git submodule update --init --recursive && echo "✔️⬇️Submodules updated correctly⬇️✔️" || echo "❌⬇️Error updating submodules⬇️❌"
        cd "$WORKING_DIR"
        ;;
    3)
        emu_version="strato"
        echo "💾Cloning Strato...💾"
        git clone --recursive -b jit https://github.com/strato-emu/strato.git "$emu_version" && echo "✔️💾Strato cloned correctly💾✔️" || echo "❌💾Error cloning Strato💾❌"
        ;;
esac
case "$emu_platform" in
    1)
        case "$emu_version" in
            citron)
                echo "⬇️Installing qt6 and sdl3...⬇️"
                sudo pacman -Syu --needed --noconfirm qt6 sdl3 && echo "✔️⬇️Qt6 and sdl3 installed correctly⬇️✔️" || echo "❌⬇️Error installing qt6 and sdl3⬇️❌"
                ;;
            torzu)
                echo "⬇️Installing qt5 sdl3 and fuse2...⬇️"
                sudo pacman -Syu --needed --noconfirm qt5 sdl3 fuse2 && echo "✔️⬇️Qt5 sdl3 and fuse2 installed correctly⬇️✔️" || echo "❌⬇️Error installing qt5 sdl3 and fuse2⬇️❌"
                ;;
        esac
        rm -rf "$emu_version.AppImage"
        cd "$emu_version"
        mkdir build && cd build
        echo "⚒️Building cmake...⚒️"
        case "$emu_version" in
            citron)
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
            torzu)
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
        case "$emu_version" in
            citron)
                mkdir -p deploy-linux/AppDir/usr/lib && cp /usr/lib/libSDL3.so* deploy-linux/AppDir/usr/lib
                cd .. && ./appimage-builder.sh citron build && echo "✔️⚒️Appimage builded correctly⚒️✔️" || echo "❌⚒️Error building appimage⚒️❌"
                chmod +x build/deploy-linux/*.AppImage && echo "✔️Permissions updated correctly✔️" || echo "❌Error updating permissions❌"
                mv build/deploy-linux/*.AppImage "$WORKING_DIR/citron.AppImage"
                ;;
            torzu)
                cd ..
                mkdir -p AppImageBuilder/build && cp /usr/lib/libSDL3.so* AppImageBuilder/build
                ./AppImage-build.sh && echo "✔️⚒️Appimage builded correctly⚒️✔️" || echo "❌⚒️Error building appimage⚒️❌"
                chmod +x *.AppImage && echo "✔️Permissions updated correctly✔️" || echo "❌Error updating permissions❌"
                mv *.AppImage "$WORKING_DIR/torzu.AppImage"
                ;;
        esac
        ;;
    2)
        echo "⬇️Installing wget and vulkan-headers...⬇️"
        sudo pacman -Syu --needed --noconfirm wget vulkan-headers && echo "✔️⬇️Wget and vulkan-headers installed correctly⬇️✔️" || echo "❌⬇️Error installing wget and vulkan-headers⬇️❌"
        rm -rf "$emu_version.apk"
        wget https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.6%2B7/OpenJDK21U-jdk_x64_linux_hotspot_21.0.6_7.tar.gz -O OpenJDK.tar.gz && echo "✔️⬇️OpenJDK downloaded correctly⬇️✔️" || echo "❌⬇️Error downloading OpenJDK⬇️❌"
        tar xzf OpenJDK.tar.gz && echo "✔️OpenJDK extracted correctly✔️" || echo "❌Error extracting OpenJDK❌"
        rm OpenJDK.tar.gz
        wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O commandlinetools.zip && echo "✔️⬇️Android SDK downloaded correctly⬇️✔️" || echo "❌⬇️Error downloading Android SDK⬇️❌"
        mkdir -p Android/Sdk/cmdline-tools
        unzip commandlinetools.zip -d Android/Sdk/cmdline-tools && echo "✔️Android SDK extracted correctly✔️" || echo "❌Error extracting Android SDK❌"
        rm commandlinetools.zip
        mv Android/Sdk/cmdline-tools/cmdline-tools Android/Sdk/cmdline-tools/latest
        export JAVA_HOME="$WORKING_DIR"/jdk-21.0.6+7
        export PATH=$PATH:$JAVA_HOME/bin
        export ANDROID_SDK_ROOT="$WORKING_DIR"/Android/Sdk
        export PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin
        export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools
        if [ "$emu_version" == "citron" ]; then
            sed -i 's|set(VCPKG_HOST_TRIPLET "x64-windows")|set(VCPKG_HOST_TRIPLET "x64-linux")|g' "$emu_version/CMakeLists.txt"
        fi
        yes | sdkmanager --licenses
        echo "⚒️Building apk...⚒️"
        if [ "$emu_version" == "strato" ]; then
            cd "$emu_version"
            ./gradlew assembleMainlineRelease && echo "✔️⚒️Apk builded correctly⚒️✔️" || echo "❌⚒️Error building apk⚒️❌"
        else
	        cd "$emu_version/src/android"
            ./gradlew assembleRelease && echo "✔️⚒️Apk builded correctly⚒️✔️" || echo "❌⚒️Error building apk⚒️❌"
        fi
        rm -rf "$WORKING_DIR/Android"
        rm -rf "$WORKING_DIR/jdk-21.0.6+7"
        mv app/build/outputs/apk/mainline/release/*.apk "$WORKING_DIR/$emu_version.apk"
        ;;
esac
cd "$WORKING_DIR" && rm -rf "$emu_version"