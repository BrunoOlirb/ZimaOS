#!/bin/bash

set -ouex pipefail

shopt -s nullglob

### File system

mkdir -p /var/roothome

### Install dnf5 if not installed
if ! rpm -q dnf5 >/dev/null; then
    rpm-ostree install dnf5 dnf5-plugins
fi

### DNF

echo -n "max_parallel_downloads=10" >>/etc/dnf/dnf.conf
echo -n "install_weak_deps=False" >>/etc/dnf/dnf.conf

### Packages

ADD=(
  kate
  distrobox
  kitty
  micro
  wl-clipboard
)

REMOVE=(
  firefox
  filelight
  konsole
  khelpcenter
  kinfocenter
  kjournaldbrowser
  kcharselect
  kde-connect
  kde-partitionmanager
  kdebugsettings
  krfb
  kfind
  kwalletmanager
  plasma-systemmonitor
  plasma-welcome
  plasma-welcome-fedora
  plasma-discover-rpm-ostree
  toolbox
  fedora-flathub-remote
)

dnf in -y "${ADD[@]}"

dnf rm -y "${REMOVE[@]}"

### From ublue-os main
dnf5 -y swap --repo='fedora' \
  OpenCL-ICD-Loader ocl-icd

### Flathub

mkdir -p /etc/flatpak/remotes.d/

curl --retry 3 -Lo /etc/flatpak/remotes.d/flathub.flatpakrepo https://dl.flathub.org/repo/flathub.flatpakrepo

echo "Default=true" | tee -a /etc/flatpak/remotes.d/flathub.flatpakrepo > /dev/null

flatpak remote-add --if-not-exists --system flathub /etc/flatpak/remotes.d/flathub.flatpakrepo
flatpak remote-modify --system --enable flathub

rm /usr/lib/systemd/system/flatpak-add-fedora-repos.service

### Nix

dnf in -y nix nix-daemon
mv nix /var/lib/

### Snapd

dnf in -y snapd

### So it won't reboot on Update

sed -i 's|^ExecStart=.*|ExecStart=/usr/bin/bootc update --quiet|' /usr/lib/systemd/system/bootc-fetch-apply-updates.service
sed -i 's|#AutomaticUpdatePolicy.*|AutomaticUpdatePolicy=stage|' /etc/rpm-ostreed.conf
sed -i 's|#LockLayering.*|LockLayering=true|' /etc/rpm-ostreed.conf

### Systemd

ENABLE=(
  bootc-fetch-apply-updates.service
  podman.socket
  nix.mount
  nix-daemon.service
  snap.mount
  snapd.service
)

systemctl enable "${ENABLE[@]}"

### Use CoreOS' generator for emergency/rescue boot
CSFG=/usr/lib/systemd/system-generators/coreos-sulogin-force-generator
curl -sSLo ${CSFG} https://raw.githubusercontent.com/coreos/fedora-coreos-config/refs/heads/stable/overlay.d/05core/usr/lib/systemd/system-generators/coreos-sulogin-force-generator
chmod +x ${CSFG}