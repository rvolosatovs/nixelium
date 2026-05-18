# Nix-powered Linux and Darwin systems

## Architecture

- `checks` contains tests to run with `nix flake check`
- `darwinConfigurations` contains all Darwin system definitions
    - `iridium` - MacBook Pro (M5 Max)
- `darwinModules` contains all Darwin modules
- `homeModules` contains all home-manager modules
- `nixosConfigurations` contains all NixOS system definitions
    - `cobalt` - Lenovo x395
    - `osmium` - System76 Galago Pro (galp6)
- `nixosModules` contains all NixOS modules
- `overlays` contains nixpkgs overlays (e.g. tooling scripts)
    - `images` - install ISOs
    - `infrastructure` - bootstrap infra setup scripts (e.g. TLS)
    - `install` - install scripts
    - `neovim` - `neovim` configuration
    - `quake3` - quake3e with HD textures and sounds
    - `scripts` - day-to-day scripts
