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
TUI_APPS = pass git nvim rtorrent mopidy fzf
SHELL = zsh

XDG_APPS = git zsh nvim rtorrent mopidy $(GUI_APPS) user-dirs.dirs user-dirs.locale cower systemd mimeapps.list
DATA_APPS = fonts base16

HOME_DOTS = profile pam_environment xprofile xinitrc Xresources npmrc

UPDATE_CMDS = pass-update submodule-update go-update nvim-update

all: tui env gui

env: pam_environment profile user-dirs mimeapps npmrc

user-dirs: user-dirs.dirs user-dirs.locale

tui: $(TUI_APPS) $(SHELL) env

gui: $(WM) $(GUI_APPS) fonts Xresources base16

arch: all cower xinitrc gui systemd

bspwm: sxhkd

nvim:
	$(MAKE) nvim-install

nvim-install: $(XDG_DATA_HOME)/nvim/plugins
$(XDG_DATA_HOME)/nvim/plugins:
	nvim --headless -c :PlugInstall -c :GoInstallBinaries -c :UpdateRemotePlugins -c :q /tmp/install.go

fzf: ${GOPATH}/src/github.com/junegunn/fzf zsh
	ln -s $(wildcard $</shell/*.zsh) $(XDG_CONFIG_HOME)/zsh/rc
	ln -s $(wildcard $</bin/*) ~/.local/bin

${GOPATH}/src/%:
	go get -u $*

ssh:
	ssh-keygen -C "$(shell whoami)@$(shell hostname)-$(shell date -I)" -b 4096

gpg:
	scp -r $(REMOTE_USERNAME)@$(REMOTE_HOSTNAME):.config/gnupg $(HOME)/.config

pass: $(PASSWORD_STORE_DIR)
$(PASSWORD_STORE_DIR):
	git clone $(PASS_USERNAME)@$(PASS_HOSTNAME):$(PASSWORD_STORE_SUFFIX) $@

$(DATA_APPS): %: $(XDG_DATA_HOME)/%
$(XDG_DATA_HOME)/%:
	ln -s $(REL_XDG_DATA)/$* $@

$(XDG_APPS): %: $(XDG_CONFIG_HOME)/%
$(XDG_CONFIG_HOME)/%:
	ln -s $(REL_XDG_CONFIG)/$* $@

$(HOME_DOTS): %: $(HOME)/.%
$(HOME)/.%:
	ln -s $(REL_HOME)/$* $@

xdg-dirs: $(XDG_DIRS)
$(XDG_DIRS):
	mkdir -p $@

mimeapps: mimeapps.list
mimeapps.list: $(XDG_CONFIG_HOME)/mimeapps.list $(XDG_DATA_HOME)/applications/mimeapps.list
$(XDG_DATA_HOME)/applications/mimeapps.list:
	mkdir -p $(shell dirname $@)
	ln -s ../$(REL_XDG_DATA)/mimeapps.list $@

clean:
	@./clean-links.sh

update: $(UPDATE_CMDS)
pass-update: pass
	pass git pull

submodule-update:
	git submodule update --init --recursive

go-update:
	-go get -u ...

nvim-update:
	nvim --headless -c :PlugUpdate -c :GoUpdateBinaries -c :UpdateRemotePlugins -c :q /tmp/install.go

bin:
	git clone git@github.com:rvolosatovs/bin.git ${HOME}/.local/bin

.PHONY: $(TUI_APPS) $(GUI_APPS) $(XDG_APPS) $(SHELL) $(HOME_DOTS) $(UPDATE_CMDS) all clean nixos arch gui ssh env user-dirs.dirs user-dirs.locale user-dirs update gpg base16 xdg-dirs bin mimeapps nvim-install
