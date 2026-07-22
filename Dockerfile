FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    DISPLAY=:1 \
    VNC_PORT=5901 \
    NO_VNC_PORT=8080 \
    RDP_PORT=3389 \
    VNC_RESOLUTION=1024x768 \
    HOME=/root

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    locales \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen \
    && apt-get install -y --no-install-recommends \
    fluxbox xterm x11vnc xvfb xrdp xorgxrdp \
    novnc websockify \
    firefox-esr thunar mousepad \
    dbus-x11 sudo htop nano wget curl git net-tools procps \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3389 8080

ENTRYPOINT ["/entrypoint.sh"]
