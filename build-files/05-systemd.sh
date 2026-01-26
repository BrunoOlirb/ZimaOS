#!/bin/bash

set -ouex pipefail

shopt -s nullglob

system_services=(
  nix.mount
  snapd.service
  snap.mount
  snap-symlink.service
  podman.socket
  sddm.service
  firewalld.service
  nix-setup.service
  nix-daemon.service
  bootc-fetch-apply-updates.service
)

mask_services=(
  logrotate.timer
  logrotate.service
  akmods-keygen.target
  rpm-ostree-countme.timer
  rpm-ostree-countme.service
  systemd-remount-fs.service
  flatpak-add-fedora-repos.service
  NetworkManager-wait-online.service
  akmods-keygen@akmods-keygen.service
)

systemctl enable "${system_services[@]}"
systemctl mask "${mask_services[@]}"

systemctl set-default graphical.target