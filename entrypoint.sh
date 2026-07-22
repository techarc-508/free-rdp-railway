#!/bin/bash
set -e

# Auto-generate password if not set
if [ -z "$RDP_PASSWORD" ]; then
    RDP_PASSWORD=$(head /dev/urandom | tr -dc 'A-Za-z0-9' | head -c 12)
fi
RDP_USER="${RDP_USER:-user}"

echo "=========================================="
echo "  Free RDP Desktop"
echo "  User:     ${RDP_USER}"
echo "  Password: ${RDP_PASSWORD}"
echo "=========================================="

# Set passwords
echo "root:${RDP_PASSWORD}" | chpasswd

# Create user
if ! id "$RDP_USER" &>/dev/null; then
    useradd -m -s /bin/bash "$RDP_USER"
fi
echo "${RDP_USER}:${RDP_PASSWORD}" | chpasswd
usermod -aG sudo "$RDP_USER"
echo "${RDP_USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/"${RDP_USER}"

# xrdp config
cat > /etc/xrdp/startwm.sh << 'WMEOF'
#!/bin/sh
if test -r /etc/profile; then . /etc/profile; fi
if test -r ~/.profile; then . ~/.profile; fi
test -x /etc/X11/Xsession && exec /etc/X11/Xsession
exec /bin/sh /etc/X11/Xsession
WMEOF
chmod 755 /etc/xrdp/startwm.sh

echo "fluxbox" > /home/${RDP_USER}/.xsession
chown ${RDP_USER}:${RDP_USER} /home/${RDP_USER}/.xsession
echo "fluxbox" > /root/.xsession

# Create fluxbox init dir
mkdir -p /root/.fluxbox
cat > /root/.fluxbox/init << 'FEOF'
session.screen0.toolbar.visible: false
session.screen0.tabs.usePixmap: false
FEOF

# Start Xvfb
Xvfb :1 -screen 0 ${VNC_RESOLUTION}x24 -ac +extension GLX +render -noreset &
sleep 2

# Start fluxbox
DISPLAY=:1 fluxbox &
sleep 1

# Start x11vnc
x11vnc -display :1 -forever -shared -rfbport ${VNC_PORT} -nopw -noxdamage -ncache 10 -ncache_cr &

# Start xrdp
service xrdp start &

# Find noVNC path and start
NOVNC_PATH=""
for p in /usr/share/novnc /usr/share/novnc/utils; do
    [ -f "$p/vnc.html" ] || [ -f "$p/vnc_lite.html" ] && NOVNC_PATH="$p" && break
done
NOVNC_PATH="${NOVNC_PATH:-/usr/share/novnc}"
cd "$NOVNC_PATH"
websockify --web . ${NO_VNC_PORT} localhost:${VNC_PORT} &

echo "=========================================="
echo "  Services running"
echo "  RDP (client):    port ${RDP_PORT}"
echo "  noVNC (browser): port ${NO_VNC_PORT}"
echo "  Password: ${RDP_PASSWORD}"
echo "=========================================="

tail -f /dev/null
