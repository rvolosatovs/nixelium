{ config, pkgs, lib, ... }:
let
  runTerminal = "${config.resources.programs.terminal.executable.path} -d /Users/${config.resources.username}"; # TODO: fix resources program module
  brave = "/Applications/Brave\\ Browser.app/Contents/MacOS/Brave\\ Browser";
in
{
  environment.systemPackages = [
    config.services.skhd.package
  ];

  services.skhd.enable = true;
  services.skhd.skhdConfig = with config.resources.programs; ''
    alt + shift - e :       ${runTerminal} -e "${shell.executable.path} -i -c ${editor.executable.path}"
    alt + shift - o :       ${brave}
    alt - return :          ${runTerminal}

    alt - q :               chunkc tiling::window --close

    alt - h :               chunkc tiling::window --focus west
    alt - j :               chunkc tiling::window --focus south
    alt - k :               chunkc tiling::window --focus north
    alt - l :               chunkc tiling::window --focus east

    alt - c :               chunkc tiling::window --focus prev
    alt + shift - c :       chunkc tiling::window --focus next

    alt + cmd - 0 :         chunkc tiling::desktop --equalize

    alt + shift - h :       chunkc tiling::window --swap west
    alt + shift - j :       chunkc tiling::window --swap south
    alt + shift - k :       chunkc tiling::window --swap north
    alt + shift - l :       chunkc tiling::window --swap east

    alt - 1 :               chunkc tiling::desktop --focus 1
    alt - 2 :               chunkc tiling::desktop --focus 2
    alt - 3 :               chunkc tiling::desktop --focus 3
    alt - 4 :               chunkc tiling::desktop --focus 4
    alt - 5 :               chunkc tiling::desktop --focus 5
    alt - 6 :               chunkc tiling::desktop --focus 6
    alt - 7 :               chunkc tiling::desktop --focus 7
    alt - c :               chunkc tiling::desktop --focus next
    alt - x :               chunkc tiling::desktop --focus $(chunkc get _last_active_desktop)
    alt - z :               chunkc tiling::desktop --focus prev

    alt + shift - 1 :       chunkc tiling::window --send-to-desktop 1
    alt + shift - 2 :       chunkc tiling::window --send-to-desktop 2
    alt + shift - 3 :       chunkc tiling::window --send-to-desktop 3
    alt + shift - 4 :       chunkc tiling::window --send-to-desktop 4
    alt + shift - 5 :       chunkc tiling::window --send-to-desktop 5
    alt + shift - 6 :       chunkc tiling::window --send-to-desktop 6
    alt + shift - 7 :       chunkc tiling::window --send-to-desktop 7
    alt + shift - c :       chunkc tiling::window --send-to-desktop next
    alt + shift - x :       chunkc tiling::window --send-to-desktop $(chunkc get _last_active_desktop)
    alt + shift - z :       chunkc tiling::window --send-to-desktop prev

    alt + cmd - h :         chunkc tiling::window --use-temporary-ratio 0.1 --adjust-window-edge west
    alt + cmd - j :         chunkc tiling::window --use-temporary-ratio 0.1 --adjust-window-edge south
    alt + cmd - k :         chunkc tiling::window --use-temporary-ratio 0.1 --adjust-window-edge north
    alt + cmd - l :         chunkc tiling::window --use-temporary-ratio 0.1 --adjust-window-edge east

    alt + cmd + shift - h : chunkc tiling::window --use-temporary-ratio -0.1 --adjust-window-edge west
    alt + cmd + shift - j : chunkc tiling::window --use-temporary-ratio -0.1 --adjust-window-edge south
    alt + cmd + shift - k : chunkc tiling::window --use-temporary-ratio -0.1 --adjust-window-edge north
    alt + cmd + shift - l : chunkc tiling::window --use-temporary-ratio -0.1 --adjust-window-edge east

    alt + ctrl - 1 :               chunkc tiling::monitor -f 1
    alt + ctrl - 2 :               chunkc tiling::monitor -f 2
    alt + ctrl - 3 :               chunkc tiling::monitor -f 3
    alt + ctrl - c :               chunkc tiling::monitor -f next
    alt + ctrl - z :               chunkc tiling::monitor -f prev

    alt + ctrl + shift - 1 :       chunkc tiling::window --send-to-monitor 1
    alt + ctrl + shift - 2 :       chunkc tiling::window --send-to-monitor 2
    alt + ctrl + shift - 3 :       chunkc tiling::window --send-to-monitor 3
    alt + ctrl + shift - c :       chunkc tiling::window --send-to-monitor next
    alt + ctrl + shift - z :       chunkc tiling::window --send-to-monitor prev

    alt - f :               chunkc tiling::window --toggle fullscreen
    alt + shift - f :       chunkc tiling::window --toggle native-fullscreen

    alt - q :               chunkc tiling::window --toggle fade

    alt - s :               chunkc tiling::window --toggle float; chunkc tiling::window --grid-layout 4:4:1:1:2:2

    alt + shift - m :       chunkc tiling::desktop --layout bsp
    alt - m :               chunkc tiling::desktop --layout monocle
  '';
}
