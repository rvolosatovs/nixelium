{ioquake3-mac-install, ...}: let
  quake3 = pkgs: _: rec {
    quake3Paks = pkgs.stdenv.mkDerivation {
      name = "quake3-paks";
      src = ioquake3-mac-install;
      buildCommand = ''
        cat $src/dependencies/baseq3/pak0/pak0.z01 \
            $src/dependencies/baseq3/pak0/pak0.z02 \
            $src/dependencies/baseq3/pak0/pak0.z03 \
            $src/dependencies/baseq3/pak0/pak0.z04 \
            $src/dependencies/baseq3/pak0/pak0.zip > pak0-master.zip
        ${pkgs.unzip}/bin/unzip -a pak0-master.zip || true
        install -Dm444 pak0.pk3 $out/baseq3/pak0.pk3
        install -Dm444 $src/dependencies/baseq3/q3key $out/baseq3/q3key
        install -Dm444 $src/extras/extra-pack-resolution.pk3 $out/baseq3/pak9hqq37test20181106.pk3
        install -Dm444 $src/extras/quake3-live-sounds.pk3 $out/baseq3/quake3-live-soundpack.pk3
        install -Dm444 $src/extras/hd-weapons.pk3 $out/baseq3/pakxy01Tv5.pk3
      '';
      meta.description = "Quake3 paks";
    };

    quake3 = pkgs.quake3wrapper {
      name = "quake3";
      description = "quake3e with HD textures and sounds";
      paks = [
        pkgs.quake3hires
        pkgs.quake3Paks
        pkgs.quake3pointrelease
      ];
    };
  };
in
  final: prev: quake3 final prev
