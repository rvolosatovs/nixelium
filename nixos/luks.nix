{
  lib,
  vars,
  ...
}: {
  boot.initrd.luks.devices = [
    {
      name = vars.luksName;
      device = vars.luksDevice;
      preLVM = true;
      allowDiscards = lib.vars.isSSD;
    }
  ];
}
