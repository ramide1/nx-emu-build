#!/bin/bash

WORKING_DIR=$(realpath .)
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
    -DUSE_DISCORD_PRESENCE=OFF \
    -DBUNDLE_SPEEX=ON \
    -DCMAKE_BUILD_TYPE=Release && echo "✔️⚒️Cmake builded correctly⚒️✔️" || echo "❌⚒️Error building cmake⚒️❌"
echo "⚒️Building bin...⚒️"
ninja && echo "✔️⚒️Bin builded correctly⚒️✔️" || echo "❌⚒️Error building bin⚒️❌"
echo "⚒️Building appimage...⚒️"
mkdir -p deploy-linux/AppDir/usr/lib && cp /usr/lib/libSDL3.so* deploy-linux/AppDir/usr/lib
cd .. && sed -i 's|rm -rf "${DEPLOY_LINUX_APPDIR_FOLDER}"||g' appimage-builder.sh && ./appimage-builder.sh citron build && echo "✔️⚒️Appimage builded correctly⚒️✔️" || echo "❌⚒️Error building appimage⚒️❌"
chmod +x build/deploy-linux/*.AppImage && echo "✔️Permissions updated correctly✔️" || echo "❌Error updating permissions❌"
mv build/deploy-linux/*.AppImage "$WORKING_DIR/outputs/citron.AppImage"