{
  home.file.".Brewfile".text = ''
    tap "homebrew/cask"
    tap "homebrew/services"
    tap "koekeishiya/formulae"

    brew "choose-gui"
    brew "chunkwm"
    cask "brave-browser"
    cask "docker"
    cask "keybase"
    cask "libreoffice"
    cask "slack"
    cask "thunderbird"
    cask "whatsapp"
    cask "xquartz"
  '';

  home.sessionVariables.PASSWORD_STORE_DIR = toString ./../../../vendor/pass-ttn-shared;
}
