{ config, pkgs, ... }:

{
  fonts.enableFontDir = true;
  fonts.fonts = with pkgs; [
    comic-relief
    fira
    furaCode
    roboto-slab
    siji
    symbola
    terminus_font
    unifont
  ];
}
