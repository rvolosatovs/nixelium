# This overlay extends nixpkgs with a few mozilla packages.
self: super:

let
  callPackage = super.lib.callPackageWith super;
in

{
  home-manager = callPackage ./pkgs/home-manager {};
}
