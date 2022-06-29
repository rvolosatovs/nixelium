# Profian Inc. Staging Environment

## Architecture

There are two environments defined in this project:
- `testing`, where latest `main` of each project is deployed automatically by the CI
- `staging`, where latest release of each project is deployed manually (potentially automated in the future)

Each service is deployed as a [hardened systemd service](https://nixos.wiki/wiki/Systemd_Hardening).

### Steward

The `steward` service is configured with a CA certificate and key and running on unprivileged port. The service itself only handles HTTP traffic, which is transparently upgraded to TLS by [Nginx](https://nginx.org/en/) reverse proxy by using [Let's Encrypt certificates](https://letsencrypt.org/), which routes requests to ports `443` and `80` (redirected) to the underlying service.

### Drawbridge

The `drawbridge` service is configured with Steward CA certificate, as well as server certificate and key and is running on unprivileged port. The service itself handles HTTPS traffic, but is behind [Nginx](https://nginx.org/en/) reverse proxy, which routes requests to ports `443` and `80` (redirected) to the underlying service.

### Access

There are two users defined relevant for deployment:
- `ops` - is used for administrative tasks, as well as debugging, restarting services, checking the logs etc.
- `deploy` is used for deployment

## Deployment

### Dependencies

The only dependency for deployment is [`nix`](https://nixos.org/download.html), which is platform-agnostic and well-supported on Linux and MacOS.

If you do not wish to install it, you can also run it via Docker/Podman.
For example:
```sh
$ docker run -w $(pwd) -v $(pwd):$(pwd) -v $(mktemp -d):/nixpkgs nixos/nix nix --extra-experimental-features 'nix-command flakes' develop -c deploy
```
Note, if you were to do this, you probably want to avoid using a temporary directory for the `nixpkgs` cache, since then `nix` would have to download all dependencies of the project on each invocation.
Instead, it is highly recommended to store the Nix store in a persistent location (e.g. by defining a volume) to avoid having to reconstruct the cache on each invocation.

### Bootstrapping

From within [`nix develop` shell](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-develop.html):
```sh
$ bootstrap
```
This will generate keys and certificates for all hosts.

### Provisioning

From within [`nix develop` shell](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-develop.html):
```sh
$ provision
```
This will provision all hosts by initializing data directories and uploading the keys.

### Deploying changes

[`serokell/deploy-rs`](https://github.com/serokell/deploy-rs) is used for deployment. (Note, the tool does not need to be installed as it is already present in `nix` development shell)

To deploy all instances, run `deploy` from the root of this repository.

From within [`nix develop` shell](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-develop.html):
```sh
$ deploy
```

Or to deploy a specific instance:
```sh
$ deploy '.#drawbridge-testing'
```

## Project Structure

- `hosts` directory contains host-specific assets and tooling, e.g. TLS certificates and a script to generate them
- `flake.nix` contains the definitions of all nodes in the network
