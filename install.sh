#!/bin/bash

sh <(curl -L https://nixos.org/nix/install)
nix flake init -t nix-darwin --extra-experimental-features "nix-command flakes"
nix run nix-darwin  --extra-experimental-features nix-command flakes -- switch  --flake ~/nix#cybersleuth
