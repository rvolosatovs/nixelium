{ pkgs, ... }:
{
  allowBroken = false;
  allowUnfree = true;
  allowUnfreeRedistributable = true;

  packageOverrides = pkgs: {
    polybar = pkgs.polybar.override {
      mpdSupport = true;
      githubSupport = true;
    };
    chromium = pkgs.chromium.override {
      enablePepperFlash = true;
      #enableNaCl = true;
      #enableWideVine = true;
    };
    firefox-wrapper = pkgs.firefox-wrapper.override {
      enableAdobeFlash = true;
      enableDjvu = true;
      enableGoogleTalkPlugin = true;
      icedtea = true;
      #enableAdobeReader = true;
      #ffmpegSupport = true;
      #jre = false;
    };
    neovim = pkgs.neovim.override {
      vimAlias = true;
      extraPython3Packages = []; #TODO
    };
  };
}
