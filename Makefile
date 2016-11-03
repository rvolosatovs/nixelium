XDG_CONFIG_HOME ?= $(HOME)/.config
XDG_DATA_HOME ?= $(HOME)/.local/share

ZDOTDIR ?= $(XDG_CONFIG_HOME)/zsh

REMOTE_USERNAME ?= $(shell whoami)
ifeq ($(shell hostname), atom)
	REMOTE_HOSTNAME ?= nirvana
else
	REMOTE_HOSTNAME ?= atom
endif

PASSWORD_STORE_SUFFIX ?= .local/pass
PASSWORD_STORE_DIR ?= $(HOME)/$(PASSWORD_STORE_SUFFIX)
PASS_USERNAME ?= $(REMOTE_USERNAME)
PASS_HOSTNAME ?= $(REMOTE_HOSTNAME)

REL_HOME = $(shell realpath --relative-to $(HOME) $(PWD))
REL_XDG_CONFIG = $(shell realpath --relative-to $(XDG_CONFIG_HOME) $(PWD))
REL_XDG_DATA = $(shell realpath --relative-to $(XDG_DATA_HOME) $(PWD))

WM ?= bspwm

GUI_APPS = $(WM) termite fontconfig zathura sxhkd stalonetray
TUI_APPS = pass git nvim rtorrent mopidy
SHELL = zsh

XDG_APPS = git zsh nvim rtorrent mopidy $(GUI_APPS) user-dirs.dirs user-dirs.locale cower

HOME_DOTS = profile pam_environment xprofile xinitrc

UPDATE_CMDS = pass-update submodule-update go-update 

all: tui env gui
env: pam_environment profile user-dirs
user-dirs: user-dirs.dirs user-dirs.locale
tui: pass $(TUI_APPS) $(SHELL)
gui: $(WM) $(GUI_APPS) fonts
arch: all cower xinitrc gui
nixos: all xprofile gui

bspwm: sxhkd
nvim: vim-plug

vim-plug: $(XDG_CONFIG_HOME)/nvim/autoload/plug.vim
$(XDG_CONFIG_HOME)/nvim/autoload/plug.vim: $(XDG_CONFIG_HOME)/nvim
	mkdir -p $(shell dirname $@)
	-ln -s $(shell realpath --relative-to $(XDG_CONFIG_HOME)/nvim/autoload $(PWD))/vim-plug/plug.vim $@

ssh:
	ssh-keygen -C "$(shell whoami)@$(shell hostname)-$(shell date -I)" -b 4096

gpg:
	scp -r $(REMOTE_USERNAME)@$(REMOTE_HOSTNAME):.config/gnupg $(HOME)/.config

pass: $(PASSWORD_STORE_DIR)
$(PASSWORD_STORE_DIR):
	git clone $(PASS_USERNAME)@$(PASS_HOSTNAME):$(PASSWORD_STORE_SUFFIX) $@

fonts: $(XDG_DATA_HOME)/fonts
$(XDG_DATA_HOME)/fonts:
	ln -s $(REL_XDG_DATA)/fonts $@

$(XDG_APPS): %: $(XDG_CONFIG_HOME)/%
$(XDG_CONFIG_HOME)/%:
	ln -s $(REL_XDG_CONFIG)/$* $@

$(HOME_DOTS): %: $(HOME)/.%
$(HOME)/.%:
	ln -s $(REL_HOME)/$* $@

clean:
	@./clean-links.sh
	-rm -rf $(ZPLUG_HOME)
	-rm -f nvim/autoload/plug.vim

update: $(UPDATE_CMDS)
pass-update: pass
	pass git pull

submodule-update:
	git submodule update --init --recursive

go-update:
	go get -u ...


.PHONY: $(TUI_APPS) $(GUI_APPS) $(XDG_APPS) $(SHELL) $(HOME_DOTS) $(UPDATE_CMDS) all clean nixos arch gui ssh env user-dirs.dirs user-dirs.locale user-dirs update gpg
