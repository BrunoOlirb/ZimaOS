# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY --chmod=0755 build-files /

# Base Image
FROM quay.io/fedora/fedora-bootc:latest

# Systemd
COPY systemd/* /etc/systemd/system/

# Build files
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

# Copy Homebrew files from the brew image and enable
COPY --from=ghcr.io/ublue-os/brew:latest /system_files /

RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /usr/bin/systemctl preset brew-setup.service && \
    /usr/bin/systemctl preset brew-update.timer && \
    /usr/bin/systemctl preset brew-upgrade.timer


### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
