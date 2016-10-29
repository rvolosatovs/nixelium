XDG_CONFIG_HOME ?= ${HOME}/.config
XDG_DATA_HOME ?= ${HOME}/.local/share

ZDOTDIR ?= ${XDG_CONFIG_HOME}/zsh

ZPLUG_HOME ?= ${ZDOTDIR}/zplug

PASSWORD_STORE_SUFFIX = ".local/pass"
PASSWORD_STORE_DIR ?= ${HOME}/.local/pass
PASS_USERNAME ?= ${shell whoami}
PASS_HOSTNAME ?= "nirvana"

all: pass git zsh zplug nvim rtorrent gui
gui: bspwm termite fontconfig zathura fonts
arch: all cower xinitrc gui
nixos: all xprofile gui

ssh:
	ssh-keygen -C "$(shell whoami)@$(shell hostname)-$(shell date -I)" -b 4096

pass: ${PASSWORD_STORE_DIR}
${PASSWORD_STORE_DIR}:
	git clone ${PASS_USERNAME}@${PASS_HOSTNAME}:${PASSWORD_STORE_SUFFIX} $@

git: ${XDG_CONFIG_HOME}/git
${XDG_CONFIG_HOME}/git:
	ln -s ${PWD}/git $@

bspwm: ${XDG_CONFIG_HOME}/bspwm sxhkd
${XDG_CONFIG_HOME}/bspwm:
	ln -s ${PWD}/bspwm $@

sxhkd: ${XDG_CONFIG_HOME}/sxhkd
${XDG_CONFIG_HOME}/sxhkd:
	ln -s ${PWD}/sxhkd $@

termite: ${XDG_CONFIG_HOME}/termite
${XDG_CONFIG_HOME}/termite:
	ln -s ${PWD}/termite $@

fontconfig: ${XDG_CONFIG_HOME}/fontconfig
${XDG_CONFIG_HOME}/fontconfig:
	ln -s ${PWD}/fontconfig $@

zathura: ${XDG_CONFIG_HOME}/zathura
${XDG_CONFIG_HOME}/zathura:
	ln -s ${PWD}/zathura $@

rtorrent: ${XDG_CONFIG_HOME}/rtorrent
${XDG_CONFIG_HOME}/rtorrent:
	ln -s ${PWD}/rtorrent $@

cower: ${XDG_CONFIG_HOME}/cower
${XDG_CONFIG_HOME}/cower:
	ln -s ${PWD}/cower $@

fonts: ${XDG_DATA_HOME}/fonts
${XDG_DATA_HOME}/fonts:
	ln -s ${PWD}/fonts $@

zsh: ${ZDOTDIR}

${ZDOTDIR}:
	ln -s ${PWD}/zsh $@
	$(MAKE) zplug

zplug: ${ZPLUG_HOME}
${ZPLUG_HOME}:
	git clone https://github.com/zplug/zplug $@

nvim: ${XDG_CONFIG_HOME}/nvim vim-plug
${XDG_CONFIG_HOME}/nvim:
	ln -s ${PWD}/nvim $@

vim-plug: ${XDG_CONFIG_HOME}/nvim/autoload/plug.vim
${XDG_CONFIG_HOME}/nvim/autoload/plug.vim:
	curl -fLo $@ --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

xprofile: ${HOME}/.xprofile
${HOME}/.xprofile:
	ln -s ${PWD}/xprofile $@

xinitrc: ${HOME}/.xinitrc
${HOME}/.xinitrc:
	ln -s ${PWD}/xinitrc $@

clean:
	@./clean.sh

.PHONY: clean nixos arch home xprofile xinitrc gui fonts bspwm sxhkd pass ssh git zsh zplug nvim vim-plug cower rtorrent zathura fontconfig termite
