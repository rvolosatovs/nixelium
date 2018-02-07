{ pkgs, ... }:
{
  allowBroken = false;
  allowUnfree = true;
  allowUnfreeRedistributable = true;

  neovim.vimAlias = true;

  firefox.enableDjvu = true;
  firefox.enableGoogleTalkPlugin = true;
  #firefox.enableAdobeFlash = true;
  firefox.enableAdobeReader = false;
  firefox.jre = false;

  #chromium.enablePepperFlash = true;
  #chromium.enableWideVine = true;

  packageOverrides = pkgs: {
    polybar = pkgs.polybar.override {
      mpdSupport = true;
      githubSupport = true;
    };
  };
}
