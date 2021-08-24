{
  home.file.".Brewfile".text = ''
    brew "choose-gui"
    brew "docker"
    brew "firefox"
    brew "keybase"
    brew "koekeishiya/formulae/yabai"
    brew "thunderbird"
  '';

  home.sessionVariables.PASSWORD_STORE_DIR = toString ./../../../vendor/pass;
}
