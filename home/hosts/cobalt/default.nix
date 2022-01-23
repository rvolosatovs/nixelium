{
  imports = [
    ./../../lan.nix
  ];

  home.sessionVariables.PASSWORD_STORE_DIR = toString ./../../../vendor/pass;
  home.sessionVariables.VDPAU_DRIVER = "radeonsi";

  xdg.configFile."mpv/config".text = ''
    gpu-context=waylandvk
  '';
}
