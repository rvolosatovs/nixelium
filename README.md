# Infrastructure
Definitions of all systems I manage.

# Usage
## Bootstrapping NixOS on a remote machine
```sh
    echo "{imports = [<infrastructure/hosts/${hostname}/configuration.nix>];}" > /etc/nixos/configuration.nix
    nixos-rebuild switch -I infrastructure="https://github.com/rvolosatovs/infrastructure/archive/master.zip"
```

## Bootstrapping NixOS on a local machine
```sh
    cd ${infrastructure}
    git clone --recursive git@github.com:rvolosatovs/infrastructure.git .
    ./bootstrap ${hostname}
```
