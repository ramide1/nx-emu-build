#!/bin/bash

echo "💾Cloning Citron...💾"
git clone --recursive https://git.citron-emu.org/Citron/Citron.git && echo "✔️💾Citron cloned correctly💾✔️" || echo "❌💾Error cloning Citron💾❌"
cd Citron
mkdir build && cd build
echo "⚒️Building cmake...⚒️"
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
    -DCMAKE_BUILD_TYPE=Release && echo "✔️⚒️Cmake builded correctly⚒️✔️" || echo "❌⚒️Error building cmake⚒️❌"
echo "⚒️Building bin...⚒️"
ninja && echo "✔️⚒️Bin builded correctly⚒️✔️" || echo "❌⚒️Error building bin⚒️❌"
mkdir -p deploy-linux/AppDir/usr/lib && cp /usr/lib/libSDL3.so* deploy-linux/AppDir/usr/lib
echo "⚒️Building appimage...⚒️"
cd .. && ./appimage-builder.sh citron build && echo "✔️⚒️Appimage builded correctly⚒️✔️" || echo "❌⚒️Error building appimage⚒️❌"
chmod +x build/deploy-linux/citron-nightly-*-x86_64.AppImage && echo "✔️Permissions updated correctly✔️" || echo "❌Error updating permissions❌"
mv build/deploy-linux/citron-nightly-*-x86_64.AppImage ../outputs