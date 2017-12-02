self: super:

let
  callPackage = super.lib.callPackageWith super;
in

{
  #home-manager = callPackage ../home-manager {};
}
