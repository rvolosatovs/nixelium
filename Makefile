XDG_CONFIG_HOME ?= ${HOME}/.config
XDG_DATA_HOME ?= ${HOME}/.local/share

ZDOTDIR ?= ${XDG_CONFIG_HOME}/zsh

ZPLUG_HOME ?= ${ZDOTDIR}/zplug

PASSWORD_STORE_SUFFIX = ".local/pass"
PASSWORD_STORE_DIR ?= ${HOME}/.local/pass
PASS_USERNAME ?= ${shell whoami}
PASS_HOSTNAME ?= "nirvana"

REL_HOME = $(shell realpath --relative-to ${HOME} ${PWD})
REL_XDG_CONFIG = $(shell realpath --relative-to ${XDG_CONFIG_HOME} ${PWD})
REL_XDG_DATA = $(shell realpath --relative-to ${XDG_DATA_HOME} ${PWD})

all: pass git zsh zplug nvim rtorrent gui env
env: pam_environment profile
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
	ln -s ${REL_XDG_CONFIG}/git $@

bspwm: ${XDG_CONFIG_HOME}/bspwm sxhkd
${XDG_CONFIG_HOME}/bspwm:
	ln -s ${REL_XDG_CONFIG}/bspwm $@

sxhkd: ${XDG_CONFIG_HOME}/sxhkd
${XDG_CONFIG_HOME}/sxhkd:
	ln -s ${REL_XDG_CONFIG}/sxhkd $@

termite: ${XDG_CONFIG_HOME}/termite
${XDG_CONFIG_HOME}/termite:
	ln -s ${REL_XDG_CONFIG}/termite $@

fontconfig: ${XDG_CONFIG_HOME}/fontconfig
${XDG_CONFIG_HOME}/fontconfig:
	ln -s ${REL_XDG_CONFIG}/fontconfig $@

zathura: ${XDG_CONFIG_HOME}/zathura
${XDG_CONFIG_HOME}/zathura:
	ln -s ${REL_XDG_CONFIG}/zathura $@

rtorrent: ${XDG_CONFIG_HOME}/rtorrent
${XDG_CONFIG_HOME}/rtorrent:
	ln -s ${REL_XDG_CONFIG}/rtorrent $@

cower: ${XDG_CONFIG_HOME}/cower
${XDG_CONFIG_HOME}/cower:
	ln -s ${REL_XDG_CONFIG}/cower $@

fonts: ${XDG_DATA_HOME}/fonts
${XDG_DATA_HOME}/fonts:
	ln -s ${REL_XDG_DATA}/fonts $@

zsh: ${ZDOTDIR}

${ZDOTDIR}:
	ln -s ${REL_XDG_CONFIG}/zsh $@
	$(MAKE) zplug

zplug: ${ZPLUG_HOME}
${ZPLUG_HOME}:
	git clone https://github.com/zplug/zplug $@

nvim: ${XDG_CONFIG_HOME}/nvim
${XDG_CONFIG_HOME}/nvim:
	ln -s ${REL_XDG_CONFIG}/nvim $@
	$(MAKE) vim-plug

vim-plug: ${XDG_CONFIG_HOME}/nvim/autoload/plug.vim
${XDG_CONFIG_HOME}/nvim/autoload/plug.vim:
	curl -fLo $@ --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

profile: ${HOME}/.profile
${HOME}/.profile:
	ln -s ${REL_HOME}/profile $@

pam_environment: ${HOME}/.pam_environment
${HOME}/.pam_environment:
	ln -s ${REL_HOME}/pam_environment $@

xprofile: ${HOME}/.xprofile
${HOME}/.xprofile:
	ln -s ${REL_HOME}/xprofile $@

xinitrc: ${HOME}/.xinitrc
${HOME}/.xinitrc:
	ln -s ${REL_HOME}/xinitrc $@

clean:
	@./clean.sh

.PHONY: clean nixos arch home xprofile xinitrc gui fonts bspwm sxhkd pass ssh git zsh zplug nvim vim-plug cower rtorrent zathura fontconfig termite profile pam_environment env
