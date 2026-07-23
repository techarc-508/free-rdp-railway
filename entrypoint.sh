#!/bin/bash
set -e

RDP_PASSWORD="${RDP_PASSWORD:-$(head /dev/urandom | tr -dc 'A-Za-z0-9' | head -c 12)}"
RDP_USER="${RDP_USER:-user}"
BORE_SERVER="${BORE_SERVER:-bore.pub}"
BORE_SECRET="${BORE_SECRET:-railwayfree2026}"

echo "=========================================="
echo "  Free RDP Desktop (NoMachine + Bore)"
echo "  User:     ${RDP_USER}"
echo "  Password: ${RDP_PASSWORD}"
echo "  Bore:     ${BORE_SERVER}"
echo "=========================================="

# Passwords
echo "root:${RDP_PASSWORD}" | chpasswd
if ! id "$RDP_USER" &>/dev/null; then
    useradd -m -s /bin/bash "$RDP_USER"
fi
echo "${RDP_USER}:${RDP_PASSWORD}" | chpasswd
usermod -aG sudo "$RDP_USER"
echo "${RDP_USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/"${RDP_USER}"

# Create .xsession
echo "fluxbox" > /home/${RDP_USER}/.xsession
chown ${RDP_USER}:${RDP_USER} /home/${RDP_USER}/.xsession
echo "fluxbox" > /root/.xsession

# Fluxbox config
mkdir -p /root/.fluxbox
cat > /root/.fluxbox/init << 'FEOF'
session.screen0.toolbar.visible: false
session.screen0.tabs.usePixmap: false
FEOF

# NoMachine headless config - set default desktop command
if [ -f /usr/NX/etc/node.cfg ]; then
    sed -i 's|^#DefaultDesktopCommand.*|DefaultDesktopCommand "/etc/X11/Xsession fluxbox"|' /usr/NX/etc/node.cfg
    sed -i 's|^DefaultDesktopCommand.*|DefaultDesktopCommand "/etc/X11/Xsession fluxbox"|' /usr/NX/etc/node.cfg
fi

# Start Xvfb
Xvfb :1 -screen 0 ${VNC_RESOLUTION}x24 -ac +extension GLX +render -noreset &
sleep 2

# Start fluxbox
DISPLAY=:1 fluxbox &
sleep 1

# Start x11vnc (backup browser access)
x11vnc -display :1 -forever -shared -rfbport ${VNC_PORT} -nopw -noxdamage -ncache 10 -ncache_cr -bg 2>/dev/null &

# Start noVNC (browser backup)
NOVNC_PATH=""
for p in /usr/share/novnc /usr/share/novnc/utils; do
    [ -f "$p/vnc.html" ] || [ -f "$p/vnc_lite.html" ] && NOVNC_PATH="$p" && break
done
NOVNC_PATH="${NOVNC_PATH:-/usr/share/novnc}"
cd "$NOVNC_PATH"
websockify --web . ${NO_VNC_PORT} localhost:${VNC_PORT} &

# Start NoMachine server
/usr/NX/bin/nxserver --startup 2>/dev/null || true &
sleep 3

# Start bore tunnel → NoMachine port 4000
echo "Connecting bore tunnel to ${BORE_SERVER}..."
bore local 4000 --to ${BORE_SERVER} --secret ${BORE_SECRET} &

echo "=========================================="
echo "  All services running"
echo "  Bore → NoMachine on ${BORE_SERVER}"
echo "  noVNC (browser): port ${NO_VNC_PORT}"
echo "  Password: ${RDP_PASSWORD}"
echo "  CHECK BORE LOGS ABOVE FOR PORT NUMBER"
echo "=========================================="

tail -f /dev/null
