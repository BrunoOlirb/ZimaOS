#!/bin/bash

set -ouex pipefail

shopt -s nullglob

groups=(
  core
  standard
  system-tools
  workstation-ostree-support 
  hardware-support
  input-methods
  multimedia
  networkmanager-submodules
  virtualization
  virtualization-headless
  critical-path-kde 
  critical-path-standard 
  desktop-accessibility 
  development-tools 
  admin-tools 
  base-graphical 
  container-management 
  guest-agents 
  guest-desktop-agents 
  fonts
)

exclude-groups=(
  amd*,
  nvidia*,
  chrony,
  flatpak,
  flatpak-builder,
  toolbox,
  wine,
  wireshark,
  x3270-x11,
  xmobar,
  xsel,
  chrony,
  screen,
  tigervnc,
  xdelta,
  zsh,
  PackageKit-command-not-found,
  apt,
  anaconda*,
  initial-setup
)

dnf group install -y "${groups[@]}" --with-optional --exclude="${exclude-groups[@]}"

exclude-kde=(
  PackageKit-command-not-found,
  akonadi-*,
  konsole,
  ark,
  fedora-flathub-remote,
  filelight,
  kcharselect,
  kde-connect,
  kde-partitionmanager,
  khelpcenter,
  kio-gdrive,
  krfb,
  krdp,
  kinfocenter,
  ksshaskpass,
  kunifiedpush,
  kwalletmanager5,
  pam-kwallet,
  plasma-desktop-doc,
  plasma-disks,
  plasma-drkonqi,
  plasma-systemmonitor,
  plasma-vault,
  plasma-welcome,
  signon-kwallet-extension,
  toolbox
)

dnf group install -y kde-desktop --exclude="${exclude-kde[@]}"