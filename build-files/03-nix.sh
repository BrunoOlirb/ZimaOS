#!/bin/bash

set -ouex pipefail

shopt -s nullglob

dnf in -y nix nix-daemon

tar --create --verbose --preserve-permissions \
  --same-owner \
  --file /etc/nix-setup.tar \
  -C / nix

rm -rf /nix/* /nix/.[!.]*