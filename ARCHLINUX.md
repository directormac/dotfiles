Boot into the Arch Linux install media

```sh
# Check if ntp is active and if the time is right
timedatectl

# In case it's not active you can do
timedatectl set-ntp true

# Or this
systemctl enable systemd-timesyncd.service

```

Disk Formatting

List all available disks

```sh
fdisk -l
```

Start Partitioning with the following commands

```sh
# Replace "nvme0n1" with the name of the disk you want to use

#fdisk text based
fdisk /dev/nvme0n1

#uefi only text based
gdisk /dev/nvme0n1

#gui based
cfdisk /dev/nvme0n1

#uefi only gui based
cgdisk /dev/nvme0n1
```

Recommendations at least 512Mb for boot partition and the rest can be your system

Create 2 partitions one for the boot partition and the other for the system partition

Use BTRFS

```sh
# Format the first partition as fat for boot
mkfs.fat -F 32 /dev/nvme0n1p1

# Format the root partition
mkfs.btrfs /dev/nvme0n1p2

```

Mount the root partitionto create a flat layout of btrfs

```sh
mount /dev/nvme0n1p2 /mnt

# Create a btrfs subvolume
btrfs subvol create /mnt/@
btrfs subvol create /mnt/@home

unmount /mnt
```

Mount the compression with compression using Zstd

```sh
# First setup the root partition
mount -o compress=zstc,subvol=@ /dev/nvme0n1p2 /mnt
mkdir -p /mnt/home
mount -o compress=zstc,subvol=@home /dev/nvme0n1p2 /mnt/home

# Then the boot partition
mkdir -p /mnt/efi
mount /dev/nvme0n1p1 /mnt/efi
```

Base Installation

```sh
# For intel cpu add intel-ucode and for AMD add amd-ucode

pacstrap -K /mnt base base-devel linux linux-firmware sudo vim zsh

genfstab -U /mnt >> /mnt/etc/fstab
```

Base Configuration

Chroot into freshly created file system

```sh
arch-chroot /mnt
```

Setup system locale and timezone

```sh
echo "us" >> /etc/vconsole.conf # ensure keyboard layout for tty sessions
vim /etc/locale.gen #uncomment your desired locale `ex: en_US.UTF-8` for me its `en_PH.UTF-8`
locale-gen
echo "LANG=en_PH.UTF-8" >> /etc/locale.conf
ln -sf /usr/share/zoneinfo/Asia/Manila /etc/localtime
hwclock --systohc
```

Bootloader Installation & Configuration

```sh
sudo pacman -S efibootmgr grub grub-btrfs

grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
# Generate a grub config
grub-mkconfig -o /boot/grub/grub.cfg
```

Setup hostname

```sh
echo yourhostname > /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 yourhostname" >> /etc/hosts
```

Configure Pacman

```sh
vim /etc/pacman.conf

# Uncomment the following lines

#[multilib]
#Include = /etc/pacman.d/mirrorlist

#ParallelDownloads = 5
#Color
#VerbosePkgLists

# Add the following line below Misc Options
#ILoveCandy

pacman -Syu
```

BTRFS and timeshift

```sh
sudo pacman -S btrfs-progs timeshift inotify-tools
```

Networking

```sh
pacman -S networkmanager nm-connection-editor networkmanager-openvpn networkmanager-pptp networkmanager-vpnc
systemctl enable NetworkManager

#Optional Wifi
pacman -S wireless_tools wpa_supplicant ifplugd dialog
```

FS Utilities

```sh
pacman -S p7zip unrar unarchiver unzip unace xz rsync
pacman -S nfs-utils cifs-utils ntfs-3g exfat-utils gvfs udisks2
```

Audio

```sh
pacman -S alsa-utils pipewire pipewire-pulse pipewire-jack wireplumber pavucontrol
```

Video

```sh
#General
pacman -S mesa mesa lib32-mesa vulkan-icd-loader lib32-vulkan-icd-loader lib32-pipewire

# For AMD
sudo pacman -S vulkan-radeon libva-mesa-driver mesa-vdpau lib32-vulkan-radeon

# For NVIDIA
pacman -S nvidia nvidia-utils lib32-nvidia-utils libvdpau lib32-libvdpau
```

User Setup

```sh
# Set root password
passwd
# Add a user
useradd -m -g wheel -s /bin/zsh yourusername #Setting default shell to zsh
passwd yourusername
# Add the user to sudo group

EDITOR=vim visudo

#Uncomment the line below
#%wheel ALL=(ALL) ALL
```

Can't live without packages

```sh
# Necessary
pacman -S git curl wget fuse2 lshw
# Terminal Related
pacman -S lsd bat zoxide navi btop starship lazygit wezterm alacritty yazi ueberzugpp
# Development needs
pacman -S rustup neovim

```

Unmount Everything and Reboot

```sh
exit
umount -R /mnt
reboot
```

After Initial login install your preferred desktop environment

```sh
sudo pacman -S gnome #This will install everything it needs and all its dependencies
```

AUR Helper

Paru makesure you installed rustup and set it up with `rustup toolchain install stable`

delete the directory after installation

```sh
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
```

Timeshift and grub

```sh
# Edit ExecStart for a custom timeshift auto backup
# ExecStart=/usr/bin/grub-btrfsd --syslog --timeshift-auto
sudo systemctl edit --full grub-btrfsd

# Enable grub-btrfsd service to run on boot
sudo systemctl enable grub-btrfsd
```

Essential fonts

```sh
sudo pacman -S ttf-dejavu ttf-freefont ttf-liberation ttf-droid terminus-font ttf-ubuntu-font-family ttf-roboto ttf-roboto-mono
sudo pacman -S noto-fonts noto-fonts-emoji
sudo pacman -S ttf-firacode-nerd ttf-jetbrains-mono-nerd  ttf-noto-nerd
sudo pacman -S ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-mono ttf-nerd-fonts-symbols-common
```

Greeter

```sh
sudo pacman -S ly
sudo systemctl enable ly
```

Blutooth

```sh
sudo pacman -S bluez bluez-utils blueman
sudo systemctl enable bluetooth
```

Themes and icons

```sh
sudo pacman -S arc-gtk-theme adapta-gtk-theme adw-gtk-theme materia-gtk-theme
sudo pacman -S papirus-icon-theme
```

### Sway section

```sh
sudo pacman -S sway polkit swaybg swayidle swaylock wlroots wl-clipboard
sudo pacman -S xorg-xwayland xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk
sudo pacman -S arc-gtk-theme papirus-icon-theme
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
sudo pacman -S grim slurp satty # For screenshots
sudo pacman -S waybar wf-recorder wofi rofi rofi-wayland
paru -S wlogout
```

#### Extra Themes

[Catppuccin](https://github.com/Fausto-Korpsvart/Catppuccin-GTK-Theme)

```sh
paru -S gnome-themes-extra gtk-engine-murrine sassc tokyonight-gtk-theme-git

```

#### Troubleshoot Screensharing issues

[Reference](https://github.com/emersion/xdg-desktop-portal-wlr/wiki/%22It-doesn't-work%22-Troubleshooting-Checklist)

```sh
#Set display manager
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
# Or modify the way sway is executed
sudo vim /usr/share/wayland-sessions/sway.desktop

# Replace the Exec=sway
# to
# Exec=env XDG_CURRENT_DESKTOP=sway dbus-run-session sway

```

[Useful add-ons for sway](https://github.com/swaywm/sway/wiki/Useful-add-ons-for-sway)

### Other Apps

```sh
sudo pacman -S firefox foliate evince obsidian file-roller vlc
paru -S lazygit lazydocker asdf-vm kerl

```

```sh
sudo pacman -S grim slurp wf-recorder thunar
```

### Docker install

```sh
sudo pacman -S docker docker-compose
sudo systemctl enable docker.sock

sudo groupadd docker
sudo usermod -aG docker ${USER}
newgrp docker

sudo chmod 666 /var/run/docker.sock

sudo systemctl restart docker

# Try running lazydocker
lazydocker

```

### Useful tools

```sh
# Java Related
sudo pacman -S maven gradle
# Dev Goodies
sudo pacman -S tree-sitter tree-sitter-cli zed nvim
# Terminal helpers
sudo pacman -S jq websocat pgcli redis sqlite3

```

### Install Low level tools

```sh
sudo pacman -S gcc gdb clang cmake ninja nasm boost
```

### ASDF

```sh
asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git
asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git
asdf plugin add kotlin https://github.com/asdf-community/asdf-kotlin.git
asdf plugin-add java https://github.com/halcyon/asdf-java.git


# To know
```

In your ~/.tool-versions file
This sets global default versions

```.tool-versions
nodejs 23.4.0
erlang 27.2
elixir 1.17.3-otp-27
kotlin 2.1.0
java openjdk-17
```

To get latest and valid versions

```sh
# To get latest version
asdf latest nodejs
# To get specific versions
asdf list all java openjdk
```

### Android Development

This is inlined with the following environment variables

```
export ANDROID_HOME="$HOME/.android"
export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"
```

The Studio option - Manage everything here

```sh
# Install android studio
paru -S android-studio
# Customize the installation and point to ~/.android as your sdk location

```

The Command Line Tools Options - Create devices and download sdk tools using the terminal

[Download Android Command Line Tools](https://developer.android.com/studio)

```sh

# create a `.android/cmdline-tools/latest` in your home directory
mkdir -p ~/.android/cmdline-tools/latest/
# In the directory you downloaded the zip
unzip commandlinetools-linux-*.zip
mv cmdline-tools/* ~/.android/cmdline-tools/latest
```

Utilizing the command line tools

```sh
# 1. First, let's install the matching components for Android 34
sdkmanager "build-tools;34.0.0" "platforms;android-34" "platform-tools"

# 2. Install the system image (let's use the Google APIs x86_64 version)
sdkmanager "system-images;android-34;google_apis;x86_64"

# 3. Accept any licenses if prompted
sdkmanager --licenses

# 4. (Optional) See what devices are available
avdmanager list device

# 5. Create an AVD (let's create a Pixel 6)
avdmanager create avd \
    -n pixel6_api34 \
    -k "system-images;android-34;google_apis;x86_64" \
    -d "pixel_6"

# 6. (Optional) Verify your AVD was created
avdmanager list avd
# Quick list of available AVDs
emulator -list-avds

# 7. Launch the emulator
emulator -avd pixel6_api34

## Launch Tips

# Start emulator in headless mode
emulator -avd pixel6_api34 -no-window

# Fresh state each launch
emulator -avd pixel6_api34 -no-snapshot

# Using & to background the process
emulator -avd pixel6_api34 &

# Or using nohup to keep it running even if terminal closes
nohup emulator -avd pixel6_api34 &

# If you want to suppress output, redirect to /dev/null
nohup emulator -avd pixel6_api34 > /dev/null 2>&1 &

#You can also start it normally and then press Ctrl+Z to suspend it,
#then type bg to continue it in the background.
#This is useful if you've already started the emulator and want to background it afterward.

# Delete emulator
avdmanager delete avd -n pixel6_api34
```

### Virtualization

````sh
paru -S virt-manager qemu-desktop libvirt dnsmasq

```sh
## Add yourself to libvirt group
sudo usermod -aG libvirt $(whoami)
newgrp libvirt


# Modular daemons

# 1. Stop all services related to libvirtd
sudo systemctl stop libvirtd.service
sudo systemctl stop libvirtd{,-ro,-admin,-tcp,-tls}.socket

#2. Disable all services related to libvirtd
sudo systemctl disable libvirtd.service
sudo systemctl disable libvirtd{,-ro,-admin,-tcp,-tls}.socket

#3. Enable new daemons
sudo for drv in qemu interface network nodedev nwfilter secret storage
  do
    systemctl unmask virt${drv}d.service
    systemctl unmask virt${drv}d{,-ro,-admin}.socket
    systemctl enable virt${drv}d.service
    systemctl enable virt${drv}d{,-ro,-admin}.socket
  done

#4. Start sockets for the new daemons

sudo for drv in qemu network nodedev nwfilter secret storage
  do
    systemctl start virt${drv}d{,-ro,-admin}.socket
  done

# Check list if default is existing
sudo virsh net-list --all
# Manual start default network
sudo virsh net-start default
# Set enable autostart up in the future
sudo virsh net-autostart --network default



````

```

### References

[1](https://github.com/silentz/arch-linux-install-guide)
[2](https://gist.github.com/mjkstra/96ce7a5689d753e7a6bdd92cdc169bae)
[3](https://github.com/Ataraxxia/secure-arch/blob/main/00_basic_system_installation.md)
[4](https://arch.d3sox.me/installation/live-setup)
```
