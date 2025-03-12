#!/bin/bash

WORKING_DIR=$(realpath .)
echo "💾Cloning Torzu...💾"
git clone --depth 1 https://notabug.org/litucks/torzu.git && echo "✔️💾Torzu cloned correctly💾✔️" || echo "❌💾Error cloning Torzu💾❌"
cd torzu
git submodule update --init --recursive && echo "✔️⬇️Submodules updated correctly⬇️✔️" || echo "❌⬇️Error updating submodules⬇️❌"
mkdir build && cd build
echo "⚒️Building cmake...⚒️"
cmake .. -GNinja \
    -DYUZU_ENABLE_LTO=ON \
    -DYUZU_USE_BUNDLED_VCPKG=ON \
    -DYUZU_TESTS=OFF \
    -DYUZU_USE_LLVM_DEMANGLE=OFF \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DUSE_DISCORD_PRESENCE=OFF \
    -DBUNDLE_SPEEX=ON \
    -DCMAKE_BUILD_TYPE=Release && echo "✔️⚒️Cmake builded correctly⚒️✔️" || echo "❌⚒️Error building cmake⚒️❌"
echo "⚒️Building bin...⚒️"
ninja && echo "✔️⚒️Bin builded correctly⚒️✔️" || echo "❌⚒️Error building bin⚒️❌"
echo "⚒️Building appimage...⚒️"
cd ..
mkdir -p AppImageBuilder/build && cp /usr/lib/libSDL3.so* AppImageBuilder/build
sed -i 's|rm -rf build||g' AppImageBuilder/build.sh && ./AppImage-build.sh && echo "✔️⚒️Appimage builded correctly⚒️✔️" || echo "❌⚒️Error building appimage⚒️❌"
chmod +x *.AppImage && echo "✔️Permissions updated correctly✔️" || echo "❌Error updating permissions❌"
mv *.AppImage "$WORKING_DIR/outputs/torzu.AppImage"