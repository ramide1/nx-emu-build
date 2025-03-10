#!/bin/bash

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
export EXTRA_QT_PLUGINS="svg;wayland-decoration-client;wayland-graphics-integration-client;wayland-shell-integration;waylandcompositor;xcb-gl-integration;platformthemes/libqt5ct.so"
export QMAKE="/usr/bin/qmake"
export QT_SELECT=5
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
APPIMAGE_NAME="torzu-nightly-$BUILD_DATE-$COMM_COUNT-$COMM_HASH-x86_64.AppImage"
LATEST_APPIMAGE=$(ls -1t torzu*.AppImage | head -n 1)
if [[ -z "${LATEST_APPIMAGE}" ]]; then
    >&2 echo "Error: No AppImage found for torzu"
    exit 1
fi
mv -v "$LATEST_APPIMAGE" "$APPIMAGE_NAME"
FILESIZE=$(stat -c %s "./${APPIMAGE_NAME}")
SHA256SUM=$(sha256sum "./${APPIMAGE_NAME}" | awk '{ print $1 }')
echo "$APPIMAGE_NAME"
echo "${SHA256SUM};${FILESIZE}B"
chmod +x "$APPIMAGE_NAME" && echo "✔️Permissions updated correctly✔️" || echo "❌Error updating permissions❌"
mv "$APPIMAGE_NAME" ../../../outputs