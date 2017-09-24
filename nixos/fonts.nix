{ pkgs, ... }:

{
  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      terminus_font
      dejavu_fonts
      font-awesome-ttf
      siji
      fira
      fira-mono
    ];
  };
}
