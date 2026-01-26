#!/bin/bash

set -ouex pipefail

shopt -s nullglob

pkgs=(
  ### MULTIMEDIA
  ffmpeg-free
  gdk-pixbuf2
  libopenraw
  qt6-qtmultimedia
  lame-libs
  libjxl

  ### TERMINAL
  kitty
  micro
  wl-clipboard
  distrobox

  ### FOR APPIMAGES
  fuse
)