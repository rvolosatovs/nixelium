{ config, pkgs, lib, ... }:
let
  oxygen = import <lib/eval-config.nix> {
    modules = [(import ./hosts/oxygen)]);
  }.config;
in
  {
    networking.wireguard.interfaces.wg0.peers = [ {
      endpoint = ${deployment.targetHost};
      publicKey = ${deployment.publicKey}
    }];
  }
