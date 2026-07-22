FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    DISPLAY=:1 \
    VNC_PORT=5901 \
    NO_VNC_PORT=8080 \
    RDP_PORT=3389 \
    VNC_RESOLUTION=1024x768 \
    HOME=/root

RUN echo "deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware" > /etc/apt/sources.list.d/debian.sources \
    && echo "deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware" >> /etc/apt/sources.list.d/debian.sources \
    && apt-get update -o Acquire::Retries=3 \
    && apt-get install -y --no-install-recommends --no-install-suggests \
    fluxbox xterm x11vnc xvfb xrdp xorgxrdp \
    novnc websockify \
    firefox-esr thunar mousepad \
    dbus-x11 sudo htop nano wget curl git net-tools procps locales \
    && locale-gen en_US.UTF-8 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3389 8080

ENTRYPOINT ["/entrypoint.sh"]
