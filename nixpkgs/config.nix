{ pkgs, ... }:
{
  allowBroken = false;
  allowUnfree = true;
  allowUnfreeRedistributable = true;

  neovim.vimAlias = true;
  neovim.viAlias = true;
  neovim.extraPython3Packages = []; #TODO

  #firefox.enableAdobeReader = true;
  #firefox.ffmpegSupport = true;
  #firefox.jre = false;
  firefox.enableAdobeFlash = true;
  firefox.enableDjvu = true;
  firefox.enableGoogleTalkPlugin = true;
  firefox.icedtea = true;

  #chromium.enableWideVine = true;
  chromium.enableNaCl = true;
  chromium.enablePepperFlash = true;

  polybar.mpdSupport = true;
  polybar.githubSupport = true;
}
