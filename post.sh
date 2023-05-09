#!/bin/bash
#

sudo systemctl enable --now NetworkManager

git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

sudo pacman -Syu

yay -S $(cat packages)

alias dotfiles='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
echo ".cfg" >> .gitignore
git clone --bare https://github.com/ton1ght/config $HOME/.cfg

dotfiles checkout
dotfiles config --local status.showUntrackedFiles no
