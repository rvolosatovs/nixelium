{
  home.file.".Brewfile".text = ''
    tap "homebrew/cask"
    tap "homebrew/services"
    tap "koekeishiya/formulae"

    brew "choose-gui"
    brew "chunkwm"
    brew "ykman"

    cask "brave-browser"
    cask "docker"
    cask "keybase"
    cask "libreoffice"
    cask "thunderbird"
    cask "xquartz"
  '';

  home.sessionVariables.PASSWORD_STORE_DIR = toString ./../../../vendor/pass-ttn-shared;
}
