#!/bin/bash

WORKING_DIR=$(realpath .)
echo "💾Cloning Strato...💾"
git clone --recursive -b jit https://github.com/strato-emu/strato.git && echo "✔️💾Strato cloned correctly💾✔️" || echo "❌💾Error cloning Strato💾❌"
cd strato
echo "⚒️Building apk...⚒️"
./gradlew assembleMainlineRelease && echo "✔️⚒️Apk builded correctly⚒️✔️" || echo "❌⚒️Error building apk⚒️❌"
mv app/build/outputs/apk/mainline/release/*.apk "$WORKING_DIR/outputs/strato.apk"