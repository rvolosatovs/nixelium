{ config, pkgs, lib, ... }:

{
  config = with lib; mkMerge [
    ({
      programs.zsh.dotDir = ".config/zsh";
      programs.zsh.enable = true;
      programs.zsh.enableAutosuggestions = true;
      programs.zsh.enableCompletion = true;
      programs.zsh.history.ignoreDups = true;
      programs.zsh.history.path = config.programs.zsh.dotDir + "/.zsh_history";
      programs.zsh.history.save = config.resources.histsize;
      programs.zsh.history.share = true;
      programs.zsh.history.size = config.resources.histsize;
      programs.zsh.initExtra = ''
         { ${pkgs.wego}/bin/wego ''${CITY:-"Eindhoven"} 1 2>/dev/null | head -7 | tail -6 } &|

         nixify() {
           if [ ! -e ./.envrc ]; then
             echo "use nix" > .envrc
             ${pkgs.direnv}/bin/direnv allow
           fi

           nixfile="shell.nix"
           if [ -e "default.nix" ]; then
             nixfile="default.nix"
           fi

           if [ ! -e ''${nixfile} ]; then
             cat > ''${nixfile} <<'EOF'
         with import <nixpkgs> {};
         stdenv.mkDerivation {
           name = "env";
           buildInputs = [
             go
           ];
         }
         EOF
             ''${EDITOR:-'${config.resources.programs.editor.executable.path}'} ''${nixfile}
           fi
         }

         semver() {
           set -e

           majorX=$(cut -d '.' -f1 <<< "''${1}")
           majorX=''${majorX:-"0"}
           minorX=$(cut -d '.' -f2 <<< "''${1}")
           minorX=''${minorX:-"0"}
           patchX=$(cut -d '.' -f3 <<< "''${1}")
           patchX=''${patchX%-*}
           patchX=''${patchX:-"0"}

           majorY=$(cut -d '.' -f1 <<< "''${2}")
           majorY=''${majorY:-"0"}
           minorY=$(cut -d '.' -f2 <<< "''${2}")
           minorY=''${minorY:-"0"}
           patchY=$(cut -d '.' -f3 <<< "''${2}")
           patchY=''${patchY%-*}
           patchY=''${patchY:-"0"}

           extend() {
               v=''${1}
               while [ ''${#v} -lt ''${2} ]; do
                   v=''${v}"0"
               done
               printf "%s" ''${v}
           }

           majorX=$(extend ''${majorX} ''${#majorY})
           minorX=$(extend ''${minorX} ''${#minorY})
           patchX=$(extend ''${patchX} ''${#patchY})

           majorY=$(extend ''${majorY} ''${#majorX})
           minorY=$(extend ''${minorY} ''${#minorX})
           patchY=$(extend ''${patchY} ''${#patchX})

           printf "%d%s%d\n" ''${majorX}''${minorX}''${patchX} ''${3:-" "} ''${majorY}''${minorY}''${patchY}
         }

         ver=( $(semver ''${ZSH_VERSION} "5.3") )
         if [ ''${ver[1]} -ge ''${ver[2]} ]; then
          [ -v oHISTFILE ] && echo "WARNING: oHISTFILE is getting overriden" &> 2
          oHISTFILE="$HISTFILE"

          [ -v oHISTSIZE ] && echo "WARNING: oHISTSIZE is getting overriden" &> 2
          oHISTSIZE="$HISTSIZE"

          [ -v oSAVEHIST ] && echo "WARNING: oSAVEHIST is getting overriden" &> 2
          oSAVEHIST="$SAVEHIST"
         else
          oHISTFILE="$HISTFILE"
          oHISTSIZE="$HISTSIZE"
          oSAVEHIST="$SAVEHIST"
         fi

         source "${pkgs.grml-zsh-config}/etc/zsh/zshrc"

         if [ ''${ver[1]} -ge ''${ver[2]} ]; then
          [ -v oHISTFILE ] && {export HISTFILE="$oHISTFILE"; unset oHISTFILE;}
          [ -v oHISTSIZE ] && {export HISTSIZE="$oHISTSIZE"; unset oHISTSIZE;}
          [ -v oSAVEHIST ] && {export SAVEHIST="$oSAVEHIST"; unset oSAVEHIST;}
         else
          export HISTFILE="$oHISTFILE"
          export HISTSIZE="$oHISTSIZE"
          export SAVEHIST="$oSAVEHIST"
         fi

         base16_${config.resources.base16.theme}

         source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

         bindkey -v
      '';
      programs.zsh.plugins = [
        {
          name = "base16-shell";
          src =  ./../vendor/base16-shell;
        }
      ];
      programs.zsh.sessionVariables.KEYTIMEOUT = "1";

      programs.zsh.shellAliases.bd="popd";
      programs.zsh.shellAliases.dh="dirs -v";
      programs.zsh.shellAliases.nd="pushd";

      xdg.configFile."zsh/.zshrc.local".source = ../dotfiles/zsh/zshrc.local;
    })

    (mkIf pkgs.stdenv.isDarwin {
      home.packages = with pkgs; [
        darwin-zsh-completions
      ];
    })

    (mkIf pkgs.stdenv.isLinux {
      systemd.user.services.zsh-history-backup.Install.WantedBy=["default.target"];
      systemd.user.services.zsh-history-backup.Service.ExecStart="${pkgs.copier}/bin/copier -from %h/${config.programs.zsh.history.path} -to %h/${config.programs.zsh.history.path}.bkp";
      systemd.user.services.zsh-history-backup.Service.Restart="always";
      systemd.user.services.zsh-history-backup.Unit.Description="Backup zsh history file on every write, restore on every delete";
    })
  ];
}
