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

Setup hostname

```sh
echo yourhostname > /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 yourhostname" >> /etc/hosts
```

Bootloader Installation & Configuration

```sh
sudo pacman -S efibootmgr grub grub-btrfs

grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
# Generate a grub config
grub-mkconfig -o /boot/grub/grub.cfg
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
pacman -S mesa lib32-mesa vulkan-icd-loader lib32-vulkan-icd-loader

# For AMD
pacman -S xf86-video-amdgpu vulkan-radeon amdvlk

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
pacman -S git curl wget xdg-user-dirs zip unzip p7zip htop dbus fuse2 lshw
# Optional
pacman -S lsd bat zoxide btop starship lazygit
# Development needs
pacman -S rustup neovim

```

Unmount Everything and Reboot

```sh
exit
umount -R /mnt
reboot
```

After Initial login installed your prefered desktop environment

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
sudo pacman -S ttf-dejavu ttf-freefont ttf-liberation ttf-droid terminus-font
sudo pacman -S noto-fonts noto-fonts-emoji ttf-ubuntu-font-family ttf-roboto ttf-roboto-mono
sudo pacman -S ttf-firacode-nerd ttf-jetbrains-mono-nerd
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
sudo pacman -S arc-gtk-theme adapta-gtk-theme materia-gtk-theme
sudo pacman -S papirus-icon-theme
```
