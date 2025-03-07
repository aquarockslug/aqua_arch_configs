# Maintainer: Aquarock <aqua.rock.slug@gmail.com>
# My personal arch linux setup

pkgname=aqua_arch
pkgver=0
pkgrel=0
pkgdesc="My personal zshell, zellij and neovim configuration"
arch=('i686' 'x86_64' 'armv7h')
url="https://github.com/aquarockslug/aqua_arch"
license=('GPL')
groups=('base-devel')
depends=('sudo' 'git' 'lazygit' 'zsh' 'neovim' 'glow' 'wget' 'bat' 'eza' 'duf' 'htop'
	'dust' 'ripgrep' 'peco' 'gum' 'p7zip' 'rsync' 'openssh' 'net-tools' 'openssh'
	'zsh-syntax-highlighting' 'zsh-autosuggestions' 'lf' 'ddgr' 'tldr' 'fzf')
makedepends=()
optdepends=('zellij' 'aerc' 'buku-git' 'nap-bin' 'docker' 'lazydocker')
source=("https://raw.githubusercontent.com/mafredri/zsh-async/main/async.zsh"
	"https://gist.githubusercontent.com/pwang2/a6b77bbc7f6e1f7016f6566fab774a77/raw/e4406aa664bde17baa406d35b63c78b5ca6e2065/dracula.zsh-theme"
	"https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm"
	# aqua source files
	"https://github.com/aquarockslug/aqua_arch_configs/raw/main/aqua_profile.plugin.zsh"
	"https://github.com/aquarockslug/aqua_arch_configs/raw/main/aqua_dracula_theme.zsh"
	"https://github.com/aquarockslug/aqua_arch_configs/raw/main/neovim.lua"
	"https://github.com/aquarockslug/aqua_arch_configs/raw/main/zellij.kdl"
)
sha256sums=('deefe9fecfe709a02a99cc846928a73703ffd18dd282afd5f07d8d8a593f8ea3'
            'f908dde7b88e24de555e36e9c0c7b984bea768efd3ffec02af3e688863c67ba3'
            '45961a04d2141c76a5464f65c462aa925719e2ef312e7f1fe943ddd9bbb36954'
            '00740c8e421bab3009c78abbdf072923ca6ceffd775fd6e08e7d9d82142deb67'
            'e8d123476472a1a8caeaf7e2eabad000767b6d19ffc3efa53d043b9d7a3f7c01'
            '558b7bd2404c6aa40df6f4d7ff63689182f357cbc58b89ff50617ae6854fec08'
            '8fe6cf1a373234399b3b344110fb549fe9978b595beea1a74b7e451c672ccf25')
package() {
	# % glow %
	mkdir -pv "${pkgdir}"/usr/share/glow
	echo
	(
		cat <<EOM
style: dracula
mouse: true
pager: false
width: 120
EOM
	) >>"${pkgdir}"/usr/share/glow/glow.yml

	# % lf %
	mkdir -pv "${pkgdir}"/etc/lf
	echo
	(
		cat <<EOM
cmd q quit
cmd preview_on :{{
    set ratios 1:3
    set preview
    set info
    map <tab> preview_off
}}
cmd preview_off :{{
    set nopreview
    set ratios 1
    set info size:time
    map <tab> preview_on
}}
cmd edit :{{
	preview_off
	\$zellij run -c -d right --width 80 -- nvim \$f
}}
map f \$\$EDITOR \$(fzf)
map c \$cat \$f | wcopy # copy contents of file to clipboard
preview_off
map <enter> shell
map \` !true # show the result of previous commands
map d delete
map E edit
map e \$zellij run -c --in-place --width 80 -- nvim \$f
map <right> \$zellij action move-focus-or-tab right
map <left> \$zellij action move-focus-or-tab left
EOM
	) >>"${pkgdir}"/etc/lf/lfrc

	# % zsh %
	mkdir -pv "${pkgdir}"/usr/share/zsh/themes/lib
	cp "${srcdir}"/*.zsh "${pkgdir}"/usr/share/zsh                               # move all zsh files into /usr/share/zsh
	mv "${pkgdir}"/usr/share/zsh/async.zsh "${pkgdir}"/usr/share/zsh/themes/lib/ # then move theme files
	cp "${srcdir}"/dracula.zsh-theme "${pkgdir}"/usr/share/zsh/themes/dracula.zsh-theme

	# % zellij %
	if [ -f /bin/zellij ]; then
		mkdir -pv "${pkgdir}"/etc/zellij/
		cp "${srcdir}"/zellij.kdl "${pkgdir}"/etc/zellij/config.kdl
		cp "${srcdir}"/zjstatus.wasm "${pkgdir}"/etc/zellij/
	fi

	# % neovim %
	mkdir -pv "${pkgdir}"/etc/xdg/nvim/plugin
	cp "${srcdir}"/neovim.lua "${pkgdir}"/etc/xdg/nvim/plugin/init.lua

	# % create .zshrc %
	echo
	(
		cat <<EOM
source /usr/share/zsh/themes/lib/async.zsh
source /usr/share/zsh/themes/dracula.zsh-theme
source /usr/share/zsh/aqua_profile.plugin.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
source $(if [ -f /bin/zellij ]; then zellij setup --generate-completion zsh; fi)
autoload -Uz compinit && compinit
if [[ -z \$ZELLIJ ]]; then
if [[ \$ZELLIJ_AUTO_ATTACH == "true" ]];
then zellij attach -c; else zellij -l /etc/zellij/config.kdl; fi;
if [[ \$ZELLIJ_AUTO_EXIT == "true" ]]; then exit; fi; fi
clear && ls
EOM
	) >>"${pkgdir}"/etc/zshrc

}
