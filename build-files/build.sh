#!/bin/bash

set -ouex pipefail

shopt -s nullglob

### File system

mkdir -p /var/roothome

### DNF

echo -n "max_parallel_downloads=10" >>/etc/dnf/dnf.conf
echo -n "install_weak_deps=False" >>/etc/dnf/dnf.conf

### Packages

PACKAGES=(
  ## Groups
  @core
  @standard
  @virtualization
  @development-tools
  @fonts
  @desktop-accessibility
  @workstation-ostree-support

  ## Hardware
  alsa-sof-firmware
  intel-audio-firmware
  intel-vsc-firmware
  realtek-firmware

  ## Multimedia
  alsa-ucm
  alsa-utils
  alsa-firmware
  alsa-sof-firmware
  alsa-tools-firmware
  pipewire
  pipewire-alsa
  pipewire-config-raop
  pipewire-gstreamer
  pipewire-pulseaudio
  pipewire-utils
  wireplumber
  libva-intel-media-driver
  ffmpeg-free
  gstreamer1-plugin-dav1d
  gstreamer1-plugin-libav
  gstreamer1-plugin-openh264
  gstreamer1-plugins-bad-free
  gstreamer1-plugins-good
  gstreamer1-plugins-ugly-free
  libopenraw
  libjxl
  glx-utils

  ## Network Manager
  dhcp-client
  dnsmasq
  iptables-nft
  wpa_supplicant

  ## Mesa
  mesa-dri-drivers
  mesa-vulkan-drivers

  ## Container
  podman
  distrobox
  buildah
  flatpak

  ## Misc
  fuse # for appimages
  firewall-config

  ## Desktop
  sddm
  sddm-breeze
  plasma-desktop
  plasma-discover
  plasma-discover-flatpak
  plasma-nm
  plasma-breeze
  breeze-icon-theme
  ffmpegthumbs
  ffmpegthumbnailer
  kde-gtk-config
  kde-settings-pulseaudio
  kdegraphics-thumbnailers
  kdeplasma-addons
  kdialog
  phonon-qt6-backend-vlc
  plasma-pa
  vlc-plugin-gstreamer
  sddm-kcm
  flatpak-kcm
  dolphin
  spectacle
  tkdnd

  ## Applications
  kitty

  ## Terminal
  micro
  wl-clipboard
)

dnf in -y "${PACKAGES[@]}" --exclude=fedora-flathub-remote

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
mv nix /var/lib/nix

### So it won't reboot on Update

sed -i 's|^ExecStart=.*|ExecStart=/usr/bin/bootc update --quiet|' /usr/lib/systemd/system/bootc-fetch-apply-updates.service
sed -i 's|#AutomaticUpdatePolicy.*|AutomaticUpdatePolicy=stage|' /etc/rpm-ostreed.conf
sed -i 's|#LockLayering.*|LockLayering=true|' /etc/rpm-ostreed.conf

### Systemd

ENABLE-SERVICES=(
  sddm.service
  firewalld.service
  bootc-fetch-apply-updates.service
  podman.socket
  nix.mount
  nix-daemon.service
)

MASK-SERVICES=(
  logrotate.timer
  logrotate.service
  rpm-ostree-countme.timer
  rpm-ostree-countme.service
  systemd-remount-fs.service
  NetworkManager-wait-online.service
)

systemctl mask "${MASK-SERVICES[@]}"

systemctl enable "${ENABLE-SERVICES[@]}"

systemctl set-default graphical.target

### Use CoreOS' generator for emergency/rescue boot
CSFG=/usr/lib/systemd/system-generators/coreos-sulogin-force-generator
curl -sSLo ${CSFG} https://raw.githubusercontent.com/coreos/fedora-coreos-config/refs/heads/stable/overlay.d/05core/usr/lib/systemd/system-generators/coreos-sulogin-force-generator
chmod +x ${CSFG}