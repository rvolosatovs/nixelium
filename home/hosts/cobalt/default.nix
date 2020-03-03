{
  imports = [
    ./../../lan.nix
    ./../../wine.nix
  ];

  home.sessionVariables.PASSWORD_STORE_DIR = toString ./../../../vendor/pass;

  programs.ssh.matchBlocks."neon".hostname = "neon.lan";
  programs.ssh.matchBlocks."neon-luks".hostname = "neon.lan";
  programs.ssh.matchBlocks."oxygen".hostname = "oxygen.external";
  programs.ssh.matchBlocks."oxygen-luks".hostname = "oxygen.external";
  programs.ssh.matchBlocks."zinc".hostname = "zinc.lan";
}
