# NX emu build
Build script for NX emus

## Instructions with Docker:
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

## Instructions without Docker (for any no x86_64 device with vm):
1) Download arch linux vm image from https://geo.mirror.pkgbuild.com/images/latest/Arch-Linux-x86_64-basic.qcow2

2) Rename to hda.qcow2

3) Install qemu system in mac with brew, windows from https://www.qemu.org/ and linux depends distro package manager, for example in arch linux
```bash
sudo pacman -Syu qemu-base
```

4) Run this command in same directory you have hda.qcow2
```bash
qemu-system-x86_64 -smp 4 -m 8G -hda hda.qcow2 -nic user,hostfwd=tcp::22-:22 -nographic
```
You can change amount of cores and ram editing `-smp` and `-m` params, if you are on X86_64 system, you can use `-enable-kvm`

5) Open new terminal and ssh into vm with
```bash
ssh arch@localhost
```
Use arch as password

6) Run this command in vm to build appimage or apk
```bash
curl -s https://raw.githubusercontent.com/ramide1/nx-emu-build/main/build_no_docker.sh && ./build_no_docker.sh
```

7) Run this command to view generated file
```bash
ls
```

8) Exit vm with
```bash
exit
```

9) Copy to your system with scp, for example
```bash
scp arch@localhost:/home/arch/app.AppImage .
```