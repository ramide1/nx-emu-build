# NX emu build
Build script for NX emus

## Instructions:
1) Install Docker, for example in Archlinux
```bash
sudo pacman -Syu docker
```

2) Run this command to clone repo and open
```bash
git clone https://github.com/ramide1/nx-emu-build.git && cd nx-emu-build
```

3) Run this command to build appimage or apk
```bash
./build.sh
```

4) Generated files are in outputs directory
```bash
ls outputs
```