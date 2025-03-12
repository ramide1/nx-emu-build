#!/bin/bash

WORKING_DIR=$(realpath .)
echo "💾Cloning Citron...💾"
git clone --recursive https://git.citron-emu.org/Citron/Citron.git && echo "✔️💾Citron cloned correctly💾✔️" || echo "❌💾Error cloning Citron💾❌"
sed -i 's|set(VCPKG_HOST_TRIPLET "x64-windows")|set(VCPKG_HOST_TRIPLET "x64-linux")|g' Citron/CMakeLists.txt
cd Citron/src/android
echo "⚒️Building apk...⚒️"
./gradlew assembleRelease && echo "✔️⚒️Apk builded correctly⚒️✔️" || echo "❌⚒️Error building apk⚒️❌"
mv app/build/outputs/apk/mainline/release/*.apk "$WORKING_DIR/outputs/citron.apk"