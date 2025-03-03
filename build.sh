#!/bin/bash

rm ~/x
echo "Installing deps..."
sudo pacman -Syu --needed --noconfirm base-devel cmake git glslang libzip mbedtls ninja zip unzip && echo "deps installed correctly" || { echo "error installing deps"; exit 1; }
echo "Select emu:"
echo "1) Citron"
echo "2) Torzu"
read -rp "Choose an option [1-2]: " emu_version
if [ "$emu_version" != "1" ] && [ "$emu_version" != "2" ]; then
    echo "Invalid option. Exiting."
    exit 1
fi
cd ~/
case "$emu_version" in
    1)
        emu_directory="Citron"
        echo "Cloning Citron..."
        git clone --recursive https://git.citron-emu.org/Citron/Citron.git && echo "Citron cloned correctly" || { echo "error cloning Citron"; rm -rf "$emu_directory"; exit 1; }
        ;;
    2)
        emu_directory="torzu"
        echo "Cloning Torzu..."
        git clone --depth 1 https://notabug.org/litucks/torzu.git && echo "Torzu cloned correctly" || { echo "error cloning Torzu"; rm -rf "$emu_directory"; exit 1; }
        cd torzu
        git submodule update --init --recursive && echo "submodules updated correctly" || { echo "error updating submodules"; cd ..; rm -rf "$emu_directory"; exit 1; }
        cd ..
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
                sudo pacman -Syu --needed --noconfirm qt6 && echo "qt6 installed correctly" || { echo "error installing qt6"; rm -rf "$emu_directory"; exit 1; }
                rm -rf citron-nightly-*-x86_64.AppImage
                ;;
            2)
                echo "Installing qt5..."
                sudo pacman -Syu --needed --noconfirm qt5 && echo "qt5 installed correctly" || { echo "error installing qt5"; rm -rf "$emu_directory"; exit 1; }
                rm -rf torzu*-x86_64.AppImage
                ;;
        esac
        cd "$emu_directory"
        mkdir build && cd build
        echo "Building cmake..."
        case "$emu_version" in
            1)
                echo "Select build mode:"
                echo "1) Release"
                echo "2) Steamdeck"
                echo "3) Compatibility"
                echo "4) Debug"
                read -rp "Choose an option [1-4]: " emu_build_mode
                if [ "$emu_build_mode" != "1" ] && [ "$emu_build_mode" != "2" ] && [ "$emu_build_mode" != "3" ] && [ "$emu_build_mode" != "4" ]; then
                    echo "Invalid option. Exiting."
                    cd ~/ && rm -rf "$emu_directory"
                    exit 1
                fi
                case "$emu_build_mode" in
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
                            -DCMAKE_BUILD_TYPE=Release && echo "cmake builded correctly" || { echo "error building cmake"; cd ~/; rm -rf "$emu_directory"; exit 1; }
                        ;;
                    2)
                        cmake .. -GNinja \
                            -DCITRON_ENABLE_LTO=ON \
                            -DCITRON_USE_BUNDLED_VCPKG=ON \
                            -DCITRON_TESTS=OFF \
                            -DCITRON_USE_LLVM_DEMANGLE=OFF \
                            -DCMAKE_INSTALL_PREFIX=/usr \
                            -DCMAKE_CXX_FLAGS="-march=znver2 -mtune=znver2 -Wno-error" \
                            -DCMAKE_C_FLAGS="-march=znver2 -mtune=znver2" \
                            -DUSE_DISCORD_PRESENCE=OFF \
                            -DBUNDLE_SPEEX=ON \
                            -DCMAKE_SYSTEM_PROCESSOR=x86_64 \
                            -DCMAKE_BUILD_TYPE=Release && echo "cmake builded correctly" || { echo "error building cmake"; cd ~/; rm -rf "$emu_directory"; exit 1; }
                        ;;
                    3)
                        cmake .. -GNinja \
                            -DCITRON_ENABLE_LTO=ON \
                            -DCITRON_USE_BUNDLED_VCPKG=ON \
                            -DCITRON_TESTS=OFF \
                            -DCITRON_USE_LLVM_DEMANGLE=OFF \
                            -DCMAKE_INSTALL_PREFIX=/usr \
                            -DCMAKE_CXX_FLAGS="-march=core2 -mtune=core2 -Wno-error" \
                            -DCMAKE_C_FLAGS="-march=core2 -mtune=core2" \
                            -DUSE_DISCORD_PRESENCE=OFF \
                            -DBUNDLE_SPEEX=ON \
                            -DCMAKE_SYSTEM_PROCESSOR=x86_64 \
                            -DCMAKE_BUILD_TYPE=Release && echo "cmake builded correctly" || { echo "error building cmake"; cd ~/; rm -rf "$emu_directory"; exit 1; }
                        ;;
                    4)
                        cmake .. -GNinja \
                            -DCMAKE_BUILD_TYPE=Debug \
                            -DCITRON_ENABLE_LTO=ON \
                            -DCITRON_USE_BUNDLED_VCPKG=ON \
                            -DCITRON_TESTS=OFF \
                            -DCITRON_USE_LLVM_DEMANGLE=OFF \
                            -DCMAKE_INSTALL_PREFIX=/usr \
                            -DCMAKE_CXX_FLAGS="-march=native -mtune=native -Wno-error" \
                            -DCMAKE_C_FLAGS="-march=native -mtune=native" \
                            -DUSE_DISCORD_PRESENCE=OFF \
                            -DBUNDLE_SPEEX=ON && echo "cmake builded correctly" || { echo "error building cmake"; cd ~/; rm -rf "$emu_directory"; exit 1; }
                        ;;
                esac
                ;;
            2)
                echo "Select build mode:"
                echo "1) Release"
                echo "2) Steamdeck"
                echo "3) Debug"
                read -rp "Choose an option [1-4]: " emu_build_mode
                if [ "$emu_build_mode" != "1" ] && [ "$emu_build_mode" != "2" ] && [ "$emu_build_mode" != "3" ] && [ "$emu_build_mode" != "4" ]; then
                    echo "Invalid option. Exiting."
                    cd ~/ && rm -rf "$emu_directory"
                    exit 1
                fi
                case "$emu_build_mode" in
                    1)
                        cmake .. -GNinja -DYUZU_USE_BUNDLED_VCPKG=ON -DYUZU_TESTS=OFF && echo "cmake builded correctly" || { echo "error building cmake"; cd ~/; rm -rf "$emu_directory"; exit 1; }
                        ;;
                    2)
                        cmake .. -GNinja -DYUZU_USE_BUNDLED_VCPKG=ON -DYUZU_TESTS=OFF -DYUZU_USE_LLVM_DEMANGLE=OFF && echo "cmake builded correctly" || { echo "error building cmake"; cd ~/; rm -rf "$emu_directory"; exit 1; }
                        ;;
                    3)
                        cmake .. -GNinja -DCMAKE_BUILD_TYPE=Debug -DYUZU_USE_BUNDLED_VCPKG=ON -DYUZU_TESTS=OFF && echo "cmake builded correctly" || { echo "error building cmake"; cd ~/; rm -rf "$emu_directory"; exit 1; }
                        ;;
                esac
                ;;
        esac
        echo "Building bin..."
        ninja && echo "bin builded correctly" || { echo "error building bin"; cd ~/; rm -rf "$emu_directory"; exit 1; }
        echo "Building appimage..."
        case "$emu_version" in
            1)
                cd .. && ./appimage-builder.sh citron build && echo "appimage builded correctly" || { echo "error building appimage"; cd ~/; rm -rf "$emu_directory"; exit 1; }
                chmod +x build/deploy-linux/citron-nightly-*-x86_64.AppImage && echo "permissions updated correctly" || { echo "error updating permissions"; cd ~/; rm -rf "$emu_directory"; exit 1; }
                mv build/deploy-linux/citron-nightly-*-x86_64.AppImage ~/
                ;;
            2)
                cd bin
                echo '[Desktop Entry]
                Version=1.0
                Type=Application
                Name=torzu
                GenericName=Switch Emulator
                Comment=Nintendo Switch video game console emulator
                Icon=torzu
                TryExec=yuzu
                Exec=yuzu %f
                Categories=Game;Emulator;Qt;
                MimeType=application/x-nx-nro;application/x-nx-nso;application/x-nx-nsp;application/x-nx-xci;
                Keywords=Nintendo;Switch;
                StartupWMClass=yuzu' > ./torzu.desktop
                cd ..
                echo "Installing wget..."
                sudo pacman -Syu --needed --noconfirm wget && echo "wget installed correctly" || { echo "error installing wget"; cd ~/; rm -rf "$emu_directory"; exit 1; }
                cd .. && wget https://git.citron-emu.org/Citron/Citron/raw/branch/master/appimage-builder.sh
                chmod +x appimage-builder.sh && ./appimage-builder.sh torzu build && echo "appimage builded correctly" || { echo "error building appimage"; cd ~/; rm -rf "$emu_directory"; exit 1; }
                mv build/deploy-linux/torzu*-x86_64.AppImage ~/
                ;;
        esac
        ;;
    2)
        echo "Installing wget..."
        sudo pacman -Syu --needed --noconfirm wget && echo "wget installed correctly" || { echo "error installing wget"; rm -rf "$emu_directory"; exit 1; }
        case "$emu_version" in
            1)
                rm -rf Citron-*-mainlineRelease.apk
                ;;
            2)
                rm -rf torzu-mainline-release.apk
                ;;
        esac
        wget https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.6%2B7/OpenJDK21U-jdk_x64_linux_hotspot_21.0.6_7.tar.gz -O OpenJDK.tar.gz && echo "OpenJDK downloaded correctly" || { echo "error downloading OpenJDK"; rm -rf "$emu_directory"; exit 1; }
        tar xzf OpenJDK.tar.gz && echo "OpenJDK extracted correctly" || { echo "error extracting OpenJDK"; rm -rf "$emu_directory"; exit 1; }
        rm OpenJDK.tar.gz
        wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O commandlinetools.zip && echo "Android SDK downloaded correctly" || { echo "error downloading Android SDK"; rm -rf "$emu_directory"; exit 1; }
        mkdir -p ~/Android/Sdk/cmdline-tools
        unzip commandlinetools.zip -d ~/Android/Sdk/cmdline-tools && echo "Android SDK extracted correctly" || { echo "error extracting Android SDK"; rm -rf "$emu_directory"; exit 1; }
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
        ./gradlew assembleRelease && echo "apk builded correctly" || { echo "error building apk"; cd ~/; rm -rf "$emu_directory"; exit 1; }
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
cd ~/ && rm -rf "$emu_directory"
echo "Build success. You can now copy files"
