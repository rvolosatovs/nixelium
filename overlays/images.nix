inputs @ {
  self,
  nixos-generators,
  ...
}: final: prev: let
  mkEnarxImage = format: modules:
    nixos-generators.nixosGenerate {
      inherit format;
      pkgs = final;
      modules =
        [
          "${self}/modules/common.nix"
          ({pkgs, ...}: {
            networking.firewall.allowedTCPPorts = [
              80
              443
            ];

            nixpkgs.overlays = [self.overlays.service];
            services.enarx.enable = true;
          })
        ]
        ++ modules;
    };

  mkEnarxSevImage = format: modules:
    mkEnarxImage format ([
        {
          boot.kernelModules = [
            "kvm-amd"
          ];
          boot.kernelPackages = final.linuxPackages_enarx;

          hardware.cpu.amd.sev.enable = true;
          hardware.cpu.amd.sev.mode = "0777";

          hardware.cpu.amd.updateMicrocode = true;

          services.enarx.backend = "sev";
        }
      ]
      ++ modules);

  enarx-sev-amazon = final.mkEnarxSevImage "amazon" [
    {
      amazonImage.sizeMB = 12 * 1024; # TODO: Figure out how much we actually need

      ec2.ena = false;
    }
  ];
in {
  inherit
    mkEnarxImage
    mkEnarxSevImage
    enarx-sev-amazon
    ;
}
