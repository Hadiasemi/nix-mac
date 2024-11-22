#!/bin/bash

bash <(curl -L https://nixos.org/nix/install) --daemon
#sh <(curl -L https://nixos.org/nix/install)
#nix flake init -t nix-darwin --extra-experimental-features "nix-command flakes"
nix run nix-darwin  --extra-experimental-features nix-command flakes -- switch  --flake ~/nix#cybersleuth
#darwin-rebuild switch --flake flake.nix#cybersleuth
