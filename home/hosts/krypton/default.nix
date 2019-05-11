{
  home.file.".Brewfile".text = ''
    brew "choose-gui"
    brew "docker"
    brew "docker-machine"
    brew "koekeishiya/formulae/chunkwm"
    cask "brave-browser"
    cask "keybase"
    cask "libreoffice"
    cask "slack"
    cask "thunderbird"
    cask "whatsapp"
    cask "xquartz"
  '';

  home.sessionVariables.PASSWORD_STORE_DIR = toString ./../../../vendor/pass-ttn-shared;
}
