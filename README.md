# Infrastructure
Definitions of all systems I manage.

# Usage
The following sections assume following variables to be set:
- `${hostname}` - hostname of the host being bootstrapped.
- `${infrastructure}` - path to the local checkout of this repository.

## Bootstrapping NixOS on a local machine
```sh
    git clone --recursive git@github.com:rvolosatovs/infrastructure.git ${infrastructure}
    nixos-rebuild switch -I nixos-config=${infrastructure}/nixos/hosts/${hostname} -I ${infrastructure}/vendor
```

## Bootstrapping NixOS on a remote machine
_This is not possible until https://github.com/NixOS/nix/issues/2151 is resolved_
```sh
    echo "{imports = [((builtins.fetchGit { url="https://github.com/rvolosatovs/infrastructure.git"; fetchSubmodules = true;}) + "/nixos/hosts/${hostname}")];}" > /etc/nixos/configuration.nix
    nixos-rebuild switch
```
