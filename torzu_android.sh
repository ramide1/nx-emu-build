#!/bin/bash

echo "💾Cloning Torzu...💾"
git clone --depth 1 https://notabug.org/litucks/torzu.git && echo "✔️💾Torzu cloned correctly💾✔️" || echo "❌💾Error cloning Torzu💾❌"
cd torzu
git submodule update --init --recursive && echo "✔️⬇️Submodules updated correctly⬇️✔️" || echo "❌⬇️Error updating submodules⬇️❌"
cd src/android
echo "⚒️Building apk...⚒️"
./gradlew assembleRelease && echo "✔️⚒️Apk builded correctly⚒️✔️" || echo "❌⚒️Error building apk⚒️❌"
mv app/build/outputs/apk/mainline/release/*.apk ../../../outputs/Torzu-mainline-release.apk