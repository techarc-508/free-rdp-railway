FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    DISPLAY=:1 \
    VNC_PORT=5901 \
    NO_VNC_PORT=8080 \
    RDP_PORT=3389 \
    VNC_RESOLUTION=1024x768

RUN apt-get update && apt-get install -y --no-install-recommends \
    xfce4-session \
    xfce4-terminal \
    xfce4-panel \
    xfwm4 \
    xfdesktop4 \
    xrdp \
    xorgxrdp \
    xvfb \
    x11vnc \
    novnc \
    websockify \
    dbus-x11 \
    sudo \
    locales \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3389 8080

ENTRYPOINT ["/entrypoint.sh"]
