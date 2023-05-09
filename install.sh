#!/bin/bash

HOME="/dev/mapper/MyVolGroup-home"
SWAP="/dev/mapper/MyVolGroup-swap"
ROOT="/dev/mapper/MyVolGroup-root"
BOOT="/dev/sda1"
CRYPTDEVICE="/dev/sda2"
HOSTNAME="kekpc"

USER="ton1ght"
PASS=""

mkfs.ext4 $ROOT
mkfs.ext4 $HOME
mkswap $SWAP
mkfs.fat -F 32 $BOOT

mount $ROOT /mnt
mount --mkdir $HOME /mnt/home
mount --mkdir $BOOT /mnt/boot
swapon $SWAP

pacstrap -K /mnt base linux-zen linux-zen-headers linux-firmware base-devel intel-ucode sudo zsh neovim lvm2 networkmanager git nvidia-dkms

genfstab -U /mnt > /mnt/etc/fstab

arch-chroot /mnt ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime
arch-chroot /mnt hwclock --systohc

sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/" /mnt/etc/locale.gen
arch-chroot /mnt locale-gen

echo $HOSTNAME > /mnt/etc/hostname
arch-chroot /mnt passwd
arch-chroot /mnt /bin/bash -c "useradd -m -g users -G wheel,storage,power,network,uucp -s /bin/zsh $USER"
arch-chroot /mnt passwd $USER

sed -i 's/^HOOKS=(.*)/HOOKS=(base udev keyboard keymap autodetect consolefont modconf block encrypt lvm2 filesystems resume fsck shutdown)/' /mnt/etc/mkinitcpio.conf
sed -i 's/MODULES=()/MODULES=(ext4)/' /mnt/etc/mkinitcpio.conf
sed -i 's/#Color/Color/' /mnt/etc/pacman.conf
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /mnt/etc/sudoers

arch-chroot /mnt mkinitcpio -p linux-zen

arch-chroot /mnt bootctl install

rm /mnt/boot/loader/loader.conf
echo "default arch" >> /mnt/boot/loader/loader.conf
echo "timeout 1" >> /mnt/boot/loader/loader.conf

rm /mnt/boot/loader/entries/arch.conf
echo "title Arch Linux" >> /mnt/boot/loader/entries/arch.conf
echo "linux /vmlinuz-linux-zen" >> /mnt/boot/loader/entries/arch.conf
echo "initrd /intel-ucode.img" >> /mnt/boot/loader/entries/arch.conf
echo "initrd /initramfs-linux-zen.img" >> /mnt/boot/loader/entries/arch.conf
echo "options cryptdevice=$CRYPTDEVICE:MyVolGroup root=/dev/MyVolGroup/root rw resume=/dev/MyVolGroup/swap nomodeset nouveau.modeset=0" >> /mnt/boot/loader/entries/arch.conf

cp -r ~/arch "/mnt/home/$USER"
chown -R "$USER:users" "/home/$USER/arch"

umount -R /mnt
swapoff -a
