# Description
I have 2 machines with different specs:
* Lenovo W541 running [Exherbo](http://exherbo.org/), main
* Lenovo X230 running [Void](http://www.voidlinux.eu/) 

Both run LibreSSL, Musl on Void and Glibc on Exherbo.

I do have Gentoo stable left as a backup(I like to break things)

xinitrc gets symlinked to appropriate spec

.dotsrc files in directories are needed by my dotfile managing script(for easy bootstrap, when needed)

All my configurations + /boot is stored in separate repos on my own server(including this) and I manage it all using submodules(turned out to be super handy, by the way)

This is just a mirror of my local repo with a (womewhat) cleaner and prettier logs

I almost exclusively use TUI apps (I have Chromium+Vimium for browsing, I started to like it more than Firefox), so I didn't really bother too much setting up the GTK and QT(probably am going to do that later)

# [Bspwm](https://github.com/baskerville/bspwm) with [Sxhkd](https://github.com/baskerville/sxhkd)
I don't really use this combo for the full potential(and I don't really think I need all of that), but text-based config is nice (unlike recompiling dwm each time I want to change something). I don't like i3.

Also I should spend more time on configuring it(hopefully going to do it soon)

I would prefer to migrate to Wayland ASAP, but Redshift does not work with it (yet), so I stay with good old Xorg. I am thinking about making it work with Wayland when I get more time(if ever)

# [Termite](https://github.com/thestinger/termite/)
It's a shame that it needs a patched libvte to work, but does exactly what I need and want, together with Bspwm totally eliminates purpose of Tmux for me(I have Tmux left for the times I have to do something in vconsole)

Visual mode in terminal? Yes, please!

# [Nvim](https://github.com/neovim/neovim) with [Plug.vim](https://github.com/junegunn/vim-plug) and a lot of plugins
It's actively developed, can do stuff asynchroniously OOB, has sane defaults and admittedly cleaner codebase(haven't read neither). It can run Emacs!(The last argument in 'Emacs better than Vim' destroyed)

# [Zsh](http://www.zsh.org/) with [Grml](http://grml.org/zsh/) and [Zplug](https://github.com/b4b4r07/zplug)
Because it's not as far from POSIX as f.e. Fish, AUTOCOMPLETION, it can emulate whatever, AUTOCOMPLETION, it has a big community, AUTOCOMPLETION, looks fancy, and did I say it features outstanding aoutcompletion features?

Bloatware, but makes my life easier and autocompletion menu with HJKL navigation? YESSSS

# [Chromium](https://www.chromium.org/) with [Vimium](https://vimium.github.io/)
The custom searching engines rock! Also configured Vimium keybindings to match my init.vim

Also Dmenu, Irssi, Rtorrent, Redshift, Cmus and Zathura

In case you want to use this - make a -recursive clone and either symlink everything your self or use my script(which is not on GH yet). The location of where to link is in .dotsrc . You also will need my 'bsource' script, which is not GH yet
