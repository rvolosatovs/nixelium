{ config, pkgs, lib, ... }:

let
  wiredInterface = "enp3s0f0"; # TODO: make generic
  wirelessInterface = "wlan0"; # TODO: make generic
in
  {
    config =
      with pkgs;
      lib.mkIf config.wayland.windowManager.sway.enable {  # TODO: Introduce a waybar-specific option
        home.packages = with pkgs; [
          waybar
        ];

        # TODO: Configure
        xdg.configFile."waybar/config".text = ''
          {
            "modules-left": ["sway/workspaces", "sway/mode"],
            "modules-center": ["sway/window"],
            "modules-right": ["idle_inhibitor", "pulseaudio", "network", "network#wireless", "cpu", "memory", "temperature", "backlight", "battery", "clock", "tray"],
            "sway/mode": {
                "format": "<span style=\"italic\">{}</span>"
            },
            "idle_inhibitor": {
                "format": "{icon}",
                "format-icons": {
                    "activated": "",
                    "deactivated": ""
                }
            },
            "pulseaudio": {
                "format": "{volume}% {icon} {format_source}",
                "format-bluetooth": "{volume}% {icon} {format_source}",
                "format-bluetooth-muted": " {icon} {format_source}",
                "format-muted": " {format_source}",
                "format-source": "{volume}% ",
                "format-source-muted": "",
                "format-icons": {
                    "headphone": "",
                    "hands-free": "",
                    "headset": "",
                    "phone": "",
                    "portable": "",
                    "car": "",
                    "default": ["", "", ""]
                },
                "on-click": "${pkgs.pavucontrol}/bin/pavucontrol"
            },
            "network": {
                "interface": "${wiredInterface}",
                "format-ethernet": "{ifname}: {ipaddr}/{cidr} ",
                "format-linked": "{ifname} (No IP) ",
                "format-disconnected": "Disconnected ⚠"
            },
            "network#wireless": {
                "interface": "${wirelessInterface}",
                "format-wifi": "{essid} ({signalStrength}%) ",
                "format-disconnected": "",
                "format-alt": "{ifname}: {ipaddr}/{cidr}"
            },
            "cpu": {
                "format": "{usage}% "
            },
            "memory": {
                "format": "{}% "
            },
            "temperature": {
                "critical-threshold": 80,
                "hwmon-path": "/sys/class/hwmon/hwmon2/temp2_input",
                "format": "{temperatureC}°C {icon}",
                "format-icons": ["", "", ""]
            },
            "backlight": {
                "format": "{percent}% {icon}",
                "format-icons": ["", ""]
            },
            "battery": {
                "states": {
                    "good": 75,
                    "warning": 30,
                    "critical": 15
                },
                "format": "{capacity}% {icon}",
                "format-charging": "{capacity}% ",
                "format-plugged": "{capacity}% ",
                "format-alt": "{time} {icon}",
                "format-icons": ["", "", "", "", ""]
            },
            "clock": {
                "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
                "format-alt": "{:%Y-%m-%d}"
            },
            "tray": {
                "spacing": 10
            }
          }
        '';
        xdg.configFile."waybar/style.css".text = builtins.readFile "${pkgs.waybar}/etc/xdg/waybar/style.css";
      };
    }
