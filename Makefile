XDG_CONFIG_HOME ?= $(HOME)/.config
XDG_DATA_HOME ?= $(HOME)/.local/share
XDG_DIRS = $(XDG_CONFIG_HOME) $(XDG_DATA_HOME)

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

XDG_APPS = git zsh nvim rtorrent mopidy $(GUI_APPS) user-dirs.dirs user-dirs.locale cower systemd
DATA_APPS=fonts base16

HOME_DOTS = profile pam_environment xprofile xinitrc Xresources

UPDATE_CMDS = pass-update submodule-update go-update 

all: tui env gui

env: pam_environment profile user-dirs

user-dirs: user-dirs.dirs user-dirs.locale

tui: $(TUI_APPS) $(SHELL) env

gui: $(WM) $(GUI_APPS) fonts Xresources base16

arch: all cower xinitrc gui systemd

bspwm: sxhkd

ssh:
	ssh-keygen -C "$(shell whoami)@$(shell hostname)-$(shell date -I)" -b 4096

gpg:
	scp -r $(REMOTE_USERNAME)@$(REMOTE_HOSTNAME):.config/gnupg $(HOME)/.config

pass: $(PASSWORD_STORE_DIR)
$(PASSWORD_STORE_DIR):
	git clone $(PASS_USERNAME)@$(PASS_HOSTNAME):$(PASSWORD_STORE_SUFFIX) $@

$(DATA_APPS): %: $(XDG_DATA_HOME)/%
$(XDG_DATA_HOME)/%:
	ln -sf $(REL_XDG_DATA)/$* $@

$(XDG_APPS): %: $(XDG_CONFIG_HOME)/%
$(XDG_CONFIG_HOME)/%:
	ln -sf $(REL_XDG_CONFIG)/$* $@

$(HOME_DOTS): %: $(HOME)/.%
$(HOME)/.%:
	ln -s $(REL_HOME)/$* $@

xdg-dirs: $(XDG_DIRS)
$(XDG_DIRS):
	mkdir -p $@

clean:
	@./clean-links.sh

update: $(UPDATE_CMDS)
pass-update: pass
	pass git pull

submodule-update:
	git submodule update --init --recursive

go-update:
	go get -u ...

bin:
	git clone git@github.com:rvolosatovs/bin.git ${HOME}/.local/bin

.PHONY: $(TUI_APPS) $(GUI_APPS) $(XDG_APPS) $(SHELL) $(HOME_DOTS) $(UPDATE_CMDS) all clean nixos arch gui ssh env user-dirs.dirs user-dirs.locale user-dirs update gpg base16 xdg-dirs bin
