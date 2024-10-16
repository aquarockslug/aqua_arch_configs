#!/bin/bash

# Maintainer: Aquarock <aqua.rock.slug@gmail.com>
# My personal arch linux setup

pkgname=aqua_arch
pkgver=0.1
pkgrel=1
pkgdesc="My personal zsh and nvim configuration"
arch=('i686' 'x86_64')
url="https://github.com/aquarockslug/aqua_arch"
license=('GPL')
groups=('base-devel')
depends=('sudo' 'git' 'lazygit' 'zsh' 'zellij' 'neovim' 'glow' 'wget' 'bat' 'eza' 'duf'
	'dust' 'ripgrep' 'peco' 'gum' 'p7zip' 'rsync' 'openssh' 'net-tools' 'openssh'
	'zsh-syntax-highlighting' 'zsh-autosuggestions' 'lf' 'ddgr' 'shellcheck')
makedepends=()
optdepends=('docker' 'lazydocker' 'aerc' 'nodejs' 'pnpm' 'python' 'github-cli' 'buku-git' 'tldr' 'nap-bin' 'geeqie')
source=("https://raw.githubusercontent.com/mafredri/zsh-async/main/async.zsh"
	"https://gist.githubusercontent.com/pwang2/a6b77bbc7f6e1f7016f6566fab774a77/raw/e4406aa664bde17baa406d35b63c78b5ca6e2065/dracula.zsh-theme"
	"https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm"
	# source files
	"https://github.com/aquarockslug/aqua_arch_configs/raw/main/aqua_functions.zsh"
	"https://github.com/aquarockslug/aqua_arch_configs/raw/main/aqua_profile.plugin.zsh"
	"https://github.com/aquarockslug/aqua_arch_configs/raw/main/aqua_theme.zsh"
	"https://github.com/aquarockslug/aqua_arch_configs/raw/main/init.lua"
	"https://github.com/aquarockslug/aqua_arch_configs/raw/main/config.kdl"
	"https://github.com/aquarockslug/aqua_arch_configs/raw/main/dracula.json"
)
sha256sums=('SKIP' 'SKIP' 'SKIP' 'SKIP' 'SKIP' 'SKIP' 'SKIP' 'SKIP' 'SKIP')
package() {

	# package zsh files
	mkdir -pv -m 755 "${pkgdir}"/home/aqua/.config/glow
	mkdir -pv -m 755 "${pkgdir}"/usr/share/zsh/themes/lib

	# glow theme
	# TODO: glow completion zsh
	# TODO: dont put any files in /home/aqua
	{
		echo "style: '~/.config/glow/dracula.json'"
		echo "mouse: false"
		echo "pager: false"
		echo "width: 120"
	} >>"${srcdir}"/home/aqua/.config/glow/glow.yml
	cp "${srcdir}"/dracula.json "${pkgdir}"/home/aqua/.config/glow/ # move all zsh files into /usr/share/zsh

	cp "${srcdir}"/*.zsh "${pkgdir}"/usr/share/zsh                               # move all zsh files into /usr/share/zsh
	mv "${pkgdir}"/usr/share/zsh/async.zsh "${pkgdir}"/usr/share/zsh/themes/lib/ # then move theme files
	cp "${srcdir}"/dracula.zsh-theme "${pkgdir}"/usr/share/zsh/themes/dracula.zsh-theme

	# zellij theme
	mkdir -pv -m 755 "${pkgdir}"/etc/zellij/
	cp "${srcdir}"/config.kdl "${pkgdir}"/etc/zellij/
	cp "${srcdir}"/zjstatus.wasm "${pkgdir}"/etc/zellij/

	# create .zshrc file
	{
		echo "source /usr/share/zsh/themes/lib/async.zsh"
		echo "source /usr/share/zsh/themes/dracula.zsh-theme"
		echo "source /usr/share/zsh/aqua_profile.plugin.zsh"
		echo "source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
		echo "source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh"
		echo "autoload -Uz compinit && compinit" # text completion
		echo ""
		echo "if [[ ! -f /proc/sys/fs/binfmt_misc/WSLInterop ]]; then" # don't autostart zellij when using WSL
		echo "if [[ -z \"\$ZELLIJ\" ]]; then"
		echo "if [[ '\$ZELLIJ_AUTO_ATTACH' == 'true' ]];"
		echo "then zellij attach -c; else zellij -l /etc/zellij/config.kdl; fi;"
		echo "if [[ '\$ZELLIJ_AUTO_EXIT' == 'true' ]]; then exit; fi; fi; fi"
		echo ""
		echo "clear && ls"
	} >>"${pkgdir}"/home/aqua/.zshrc

	# package neovim files
	mkdir -pv -m 755 "${pkgdir}"/etc/xdg/nvim/plugin
	cp "${srcdir}"/*.lua "${pkgdir}"/etc/xdg/nvim/plugin
}
