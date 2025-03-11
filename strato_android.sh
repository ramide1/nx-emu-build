#!/bin/bash

echo "💾Cloning Strato...💾"
git clone --recursive -b jit https://github.com/strato-emu/strato.git && echo "✔️💾Strato cloned correctly💾✔️" || echo "❌💾Error cloning Strato💾❌"
cd strato
echo "⚒️Building apk...⚒️"
./gradlew assembleMainlineRelease && echo "✔️⚒️Apk builded correctly⚒️✔️" || echo "❌⚒️Error building apk⚒️❌"
mv app/build/outputs/apk/mainline/release/*.apk ../outputs/Strato-mainline-release.apk