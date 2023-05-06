#!/bin/bash
#

sudo systemctl enable --now NetworkManager

git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

sudo pacman -Syu

