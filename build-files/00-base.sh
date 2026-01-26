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