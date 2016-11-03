XDG_CONFIG_HOME ?= $(HOME)/.config
XDG_DATA_HOME ?= $(HOME)/.local/share

ZDOTDIR ?= $(XDG_CONFIG_HOME)/zsh

PASSWORD_STORE_SUFFIX = ".local/pass"
PASSWORD_STORE_DIR ?= $(HOME)/.local/pass
PASS_USERNAME ?= $(shell whoami)
PASS_HOSTNAME ?= "nirvana"

REL_HOME = $(shell realpath --relative-to $(HOME) $(PWD))
REL_XDG_CONFIG = $(shell realpath --relative-to $(XDG_CONFIG_HOME) $(PWD))
REL_XDG_DATA = $(shell realpath --relative-to $(XDG_DATA_HOME) $(PWD))

WM ?= bspwm

GUI_APPS=$(WM) termite fontconfig zathura 
TUI_APPS=pass git nvim rtorrent mopidy
SHELL=zsh

XDG_APPS=git zsh nvim rtorrent mopidy $(GUI_APPS)

HOME_DOTS=profile pam_environment xprofile xinitrc

all: tui env 
env: pam_environment profile
tui: pass $(TUI_APPS) $(SHELL)
gui: $(WM) $(GUI_APPS) fonts
arch: all cower xinitrc gui
nixos: all xprofile gui

bspwm: sxhkd
nvim: vim-plug

vim-plug: $(XDG_CONFIG_HOME)/nvim/autoload/plug.vim
$(XDG_CONFIG_HOME)/nvim/autoload/plug.vim: $(XDG_CONFIG_HOME)/nvim
	mkdir -p $(shell dirname $@)
	cp vim-plug/plug.vim $@

ssh:
	ssh-keygen -C "$(shell whoami)@$(shell hostname)-$(shell date -I)" -b 4096

pass: $(PASSWORD_STORE_DIR)
$(PASSWORD_STORE_DIR):
	git clone $(PASS_USERNAME)@$(PASS_HOSTNAME):$(PASSWORD_STORE_SUFFIX) $@

$(XDG_APPS): %: $(XDG_CONFIG_HOME)/%
$(XDG_CONFIG_HOME)/%:
	ln -s $(REL_XDG_CONFIG)/$* $@

$(HOME_DOTS): %: $(HOME)/.%
$(HOME)/.%:
	ln -s $(REL_HOME)/$* $@

clean:
	@./clean-links.sh
	-rm -rf $(ZPLUG_HOME)
	-rm -f $(XDG_CONFIG_HOME)/nvim/autoload/plug.vim

.PHONY: $(TUI_APPS) $(GUI_APPS) $(SHELL) $(HOME_DOTS) all clean nixos arch gui ssh env
