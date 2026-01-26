#!/bin/bash

set -ouex pipefail

shopt -s nullglob

### File system

mkdir -p /var/roothome

rmdir /opt
mkdir -p /var/opt
ln -s -T /var/opt /opt

### DNF

echo -n "max_parallel_downloads=10" >>/etc/dnf/dnf.conf
echo -n "install_weak_deps=False" >>/etc/dnf/dnf.conf

### RPMFusion

dnf in -y distribution-gpg-keys

rpmkeys --import /usr/share/distribution-gpg-keys/rpmfusion/RPM-GPG-KEY-rpmfusion-free-fedora-$(rpm -E %fedora)
dnf --setopt=localpkg_gpgcheck=1 in -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
                                       https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

dnf config-manager setopt fedora-cisco-openh264.enabled=1

dnf in -y ffmpeg\
        @multimedia\
        libva-intel-driver\
        --exclude=PackageKit-gstreamer-plugin

### VS Code

rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | tee /etc/yum.repos.d/vscode.repo > /dev/null

### Packages

RM_PACKAGES=(
  firefox
  konsole
  kfind
  krfb
  kcharselect
  kde-connect
  kwalletmanager
  filelight
  kdebugsettings
  fcitx5
  kjournaldbrowser
)

dnf rm -y "${RM_PACKAGES[@]}"

ADD_PACKAGES=(
    distrobox
    kitty
    kate
    chromium
    code
    @development-tools
)

dnf in -y "${ADD_PACKAGES[@]}"

### Mailspring

dnf in -y "$(curl -s https://api.github.com/repos/Foundry376/Mailspring/releases/latest | grep browser_download_url | grep rpm | cut -d '"' -f 4)"

### Flathub

curl -Lo /etc/flatpak/remotes.d/flathub.flatpakrepo https://dl.flathub.org/repo/flathub.flatpakrepo && \
echo "Default=true" | tee -a /etc/flatpak/remotes.d/flathub.flatpakrepo > /dev/null
flatpak remote-add --if-not-exists --system flathub /etc/flatpak/remotes.d/flathub.flatpakrepo
flatpak remote-modify --system --enable flathub

### So it won't reboot on Update

sed -i 's|^ExecStart=.*|ExecStart=/usr/bin/bootc update --quiet|' /usr/lib/systemd/system/bootc-fetch-apply-updates.service
sed -i 's|#AutomaticUpdatePolicy.*|AutomaticUpdatePolicy=stage|' /etc/rpm-ostreed.conf
sed -i 's|#LockLayering.*|LockLayering=true|' /etc/rpm-ostreed.conf

### Systemd service masking

mask_services=(
  logrotate.timer
  logrotate.service
  rpm-ostree-countme.timer
  rpm-ostree-countme.service
  systemd-remount-fs.service
  flatpak-add-fedora-repos.service
  NetworkManager-wait-online.service
)

systemctl mask "${mask_services[@]}"