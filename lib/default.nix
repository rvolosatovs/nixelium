{
  self,
  nixlib,
  nixpkgs-nixos,
  ...
}: let
  luaConstTableIndex = ''function(_,k) error("attempt to get '"..k.."'") end'';
  luaConstTableNewIndex = ''function(_,k,v) error("attempt to set '"..k.."' to '"..v.."'") end'';
in
  with nixlib.lib;
  with builtins; rec {
    luaConstTable = t: "setmetatable(${t},{__index=${luaConstTableIndex}, __newindex=${luaConstTableNewIndex}})";

    emptyLuaConstTable = luaConstTable "{}";

    toLua = v:
      if isAttrs v
      then luaConstTable ''{${concatStringsSep "," (mapAttrsToList (sk: sv: "['${sk}']=${toLua sv}") v)}}''
      else if isList v
      then
        if length v == 0
        then luaConstTable "{}"
        else throw "non-empty lists are not supported"
      else toJSON v;

    mkNixosInstallIsoSystem = {
      modules ? [],
      nixpkgs ? nixpkgs-nixos,
      system,
    }:
      nixpkgs-nixos.lib.nixosSystem {
        inherit system;
        modules = [
          ({pkgs, ...}: {
            imports =
              [
                "${nixpkgs-nixos}/nixos/modules/installer/cd-dvd/channel.nix"
                "${nixpkgs-nixos}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"

                self.nixosModules.default
              ]
              ++ modules;
          })
        ];
      };
  }
