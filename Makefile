SHELL = /usr/bin/env bash

ZDOTDIR ?= $(XDG_CONFIG_HOME)/zsh

GOPATH ?= $(HOME)

USE_HTTPS ?=

REMOTE_USERNAME ?= $(shell whoami)
ifeq ($(shell hostname), neon)
	REMOTE_HOSTNAME ?= nirvana
else
	REMOTE_HOSTNAME ?= neon
endif

PASSWORD_STORE_SUFFIX ?= .local/pass
PASSWORD_STORE_DIR ?= $(HOME)/$(PASSWORD_STORE_SUFFIX)
PASS_USERNAME ?= $(REMOTE_USERNAME)
PASS_HOSTNAME ?= $(REMOTE_HOSTNAME)

XDG_CONFIG_HOME ?= $(HOME)/.config
XDG_DATA_HOME ?= $(HOME)/.local/share
XDG_DIRS = $(XDG_CONFIG_HOME) $(XDG_DATA_HOME)

REL_HOME = $(shell realpath --relative-to $(HOME) $(PWD))
REL_XDG_CONFIG = $(shell realpath --relative-to $(XDG_CONFIG_HOME) $(PWD))
REL_XDG_DATA = $(shell realpath --relative-to $(XDG_DATA_HOME) $(PWD))

GUI_DOTS = bspwm themes termite fontconfig zathura sxhkd stalonetray
TUI_DOTS = git nvim rtorrent mopidy

HOME_DOTS = profile pam_environment themes xprofile xinitrc Xresources npmrc
XDG_DOTS = $(GUI_DOTS) git zsh nvim mopidy systemd user-dirs.dirs user-dirs.locale mimeapps.list
DATA_DOTS = fonts base16

DATE ?= $(shell date +%y%m%d)

NVIM_CMD ?= nvim -m -n --headless /tmp/install.go

all: bin tui env

arch: all cower xinitrc systemd

nixos: all nixpkgs

env: user-dirs.dirs user-dirs.locale mimeapps npmrc

tui: $(TUI_DOTS) env

gui: $(GUI_DOTS) bspwm fonts Xresources base16 env

bspwm: sxhkd

nvim:
	@$(MAKE) nvim-install

nvim-install: $(XDG_DATA_HOME)/nvim/plugins
$(XDG_DATA_HOME)/nvim/plugins:
	$(info Installing neovim plugins...)
	@$(NVIM_CMD) -c :PlugInstall -c :UpdateRemotePlugins -c :qa!
	@$(NVIM_CMD) -c :GoInstallBinaries -c :qa!

$(GOPATH)/src/%:
	go get -u $*

SSH_COMMENT="$(shell whoami)@$(shell hostname)"
ssh:
	$(info Generating ssh keys...)
	@ssh-keygen -a 100 -C $(SSH_COMMENT) -t ed25519 -f ~/.ssh/id_ed25519_$(DATE)
	@ssh-keygen -a 100 -C $(SSH_COMMENT) -t rsa -f ~/.ssh/id_rsa_$(DATE) -o -b 4096
	$(info Updating ssh key symlinks...)
	@ln -sf id_ed25519_$(DATE)       ~/.ssh/id_ed25519
	@ln -sf id_ed25519_$(DATE).pub   ~/.ssh/id_ed25519.pub
	@ln -sf id_rsa_$(DATE)           ~/.ssh/id_rsa
	@ln -sf id_rsa_$(DATE).pub       ~/.ssh/id_rsa.pub

gpg:
	$(info Copying GPG keychain from $(REMOTE_USERNAME)@$(REMOTE_HOSTNAME)...)
	@scp -r $(REMOTE_USERNAME)@$(REMOTE_HOSTNAME):.config/gnupg $(HOME)/.config

pass: $(PASSWORD_STORE_DIR)
$(PASSWORD_STORE_DIR):
	$(info Cloning pass store from $(REMOTE_USERNAME)@$(REMOTE_HOSTNAME)...)
	@git clone $(PASS_USERNAME)@$(PASS_HOSTNAME):$(PASSWORD_STORE_SUFFIX) $@

$(DATA_DOTS): %: $(XDG_DATA_HOME)/%
$(XDG_DATA_HOME)/%:
	$(info Linking $* to $@...)
	@ln -s $(REL_XDG_DATA)/$* $@

$(XDG_DOTS): %: $(XDG_CONFIG_HOME)/%
$(XDG_CONFIG_HOME)/%:
	$(info Linking $* to $@...)
	@ln -s $(REL_XDG_CONFIG)/$* $@

$(HOME_DOTS): %: $(HOME)/.%
$(HOME)/.%:
	$(info Linking $* to $@...)
	@ln -s $(REL_HOME)/$* $@

xdg-dirs: $(XDG_DIRS)
$(XDG_DIRS):
	@mkdir -p $@

mimeapps: mimeapps.list
mimeapps.list: $(XDG_CONFIG_HOME)/mimeapps.list $(XDG_DATA_HOME)/applications/mimeapps.list
$(XDG_DATA_HOME)/applications/mimeapps.list:
	$(info Linking $* to $@...)
	@mkdir -p $(shell dirname $@)
	@ln -s ../$(REL_XDG_DATA)/mimeapps.list $@

UPDATE_CMDS = pass-update submodule-update go-update nvim-update

update: $(UPDATE_CMDS)

pass-update: pass
	@pass git pull

submodule-update:
	$(info Cloning binaries...)
	@git submodule update --init --recursive --remote --rebase

go-update:
	-go get -u ...

nvim-update:
	$(info Updating neovim plugins...)
	@$(NVIM_CMD) -c :PlugUpdate -c :UpdateRemotePlugins -c :qa!

bin: $(HOME)/.local/bin

$(HOME)/.local/bin:
	$(info Cloning binaries...)
ifdef USE_HTTPS
	@git clone https://github.com/rvolosatovs/bin $@
else
	@git clone git@github.com:rvolosatovs/bin.git $@
endif

nixpkgs: $(GOPATH)/src/github.com/rvolosatovs/nixpkgs /nix/nixpkgs

$(GOPATH)/src/github.com/rvolosatovs/nixpkgs:
	$(info Cloning nixpkgs...)
ifdef USE_HTTPS
	@git clone https://github.com/rvolosatovs/nixpkgs $@
else
	@git clone git@github.com:rvolosatovs/nixpkgs.git $@
endif

/nix/nixpkgs: $(GOPATH)/src/github.com/rvolosatovs/nixpkgs
	$(info Linking $< to $@...)
	@sudo ln -s $< $@

.PHONY: $(TUI_DOTS) $(GUI_DOTS) $(XDG_DOTS) $(HOME_DOTS) $(UPDATE_CMDS) all clean nixos arch gui ssh zsh env user-dirs.dirs user-dirs.locale update gpg base16 xdg-dirs bin mimeapps nvim-install nixpkgs bin
