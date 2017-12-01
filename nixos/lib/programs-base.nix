{ config, pkgs, lib, ...}:

with lib;

let 
  mypkgs = import <mypkgs> {};
  unstable = import <nixpkgs-unstable> {};
in
{
  networking.networkmanager.enable = true;
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      (self: super: with builtins;
      let
        # isNewer reports whether version of a is higher, than b
        isNewer = { a, b }: compareVersions a.version b.version == 1;

        # newest returns derivation with same name as pkg from super
        # if it's version is higher than version on pkg. pkg otherwise.
        newest = pkg:
        let
          name = (parseDrvName pkg.name).name;
          inSuper = if hasAttr name super then getAttr name super else null;
        in
        if (inSuper != null) && (isNewer { a = inSuper; b = pkg;} )
        then inSuper
        else pkg;
      in
      {
        #browserpass = newest mypkgs.browserpass;
        #go = unstable.go;
        mopidy-iris = newest mypkgs.mopidy-iris;
        #mopidy-local-sqlite = newest mypkgs.mopidy-local-sqlite;
        #mopidy-local-images = newest mypkgs.mopidy-local-images;
        #mopidy-mpris = newest mypkgs.mopidy-mpris;
        #neovim = newest mypkgs.neovim;
        #keybase = newest mypkgs.keybase;
        #ripgrep = unstable.ripgrep;
        #rclone = mypkgs.rclone;
      })
    ];
  };
}
