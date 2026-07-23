FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    DISPLAY=:1 \
    VNC_PORT=5901 \
    NO_VNC_PORT=8080 \
    RDP_PORT=3389 \
    VNC_RESOLUTION=1024x768 \
    HOME=/root

# Install bore first (static binary, no deps)
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl ca-certificates \
    && BORE_VERSION=$(curl -s https://api.github.com/repos/ekzhang/bore/releases/latest | grep tag_name | cut -d '"' -f4) \
    && curl -sL "https://github.com/ekzhang/bore/releases/download/${BORE_VERSION}/bore-${BORE_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
    | tar xz -C /usr/local/bin \
    && chmod +x /usr/local/bin/bore \
    && apt-get purge -y curl ca-certificates \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Install desktop + VNC + noVNC
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    fluxbox xterm x11vnc xvfb novnc websockify \
    dbus-x11 sudo htop wget procps locales \
    && locale-gen en_US.UTF-8 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080 3389

ENTRYPOINT ["/entrypoint.sh"]
