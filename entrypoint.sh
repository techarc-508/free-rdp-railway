#!/bin/bash
set -e

RDP_PASSWORD="${RDP_PASSWORD:-password}"
RDP_USER="${RDP_USER:-user}"

echo "=== Setting up user: ${RDP_USER} ==="

echo "root:${RDP_PASSWORD}" | chpasswd

if ! id "$RDP_USER" &>/dev/null; then
    useradd -m -s /bin/bash "$RDP_USER"
fi
echo "${RDP_USER}:${RDP_PASSWORD}" | chpasswd
usermod -aG sudo "$RDP_USER"
echo "${RDP_USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/"${RDP_USER}"

# Fix xrdp startwm.sh
cat > /etc/xrdp/startwm.sh << 'WMEOF'
#!/bin/sh
if test -r /etc/profile; then . /etc/profile; fi
if test -r ~/.profile; then . ~/.profile; fi
test -x /etc/X11/Xsession && exec /etc/X11/Xsession
exec /bin/sh /etc/X11/Xsession
WMEOF
chmod 755 /etc/xrdp/startwm.sh

echo "xfce4-session" > /home/${RDP_USER}/.xsession
chown ${RDP_USER}:${RDP_USER} /home/${RDP_USER}/.xsession

echo "=== Starting services ==="

# Virtual display
Xvfb :1 -screen 0 ${VNC_RESOLUTION}x24 -ac +extension GLX +render -noreset &
sleep 2

# VNC with compression for speed
x11vnc -display :1 -forever -shared -rfbport ${VNC_PORT} \
    -nopw -xkb -ncache 10 -ncache_cr -bgr2rgb \
    -quality 60 -noxdamage &
sleep 1

# xrdp
service xrdp start &

# noVNC - find correct path
NOVNC_PATH=""
for p in /usr/share/novnc /usr/share/novnc/utils; do
    if [ -f "$p/vnc.html" ] || [ -f "$p/vnc_lite.html" ]; then
        NOVNC_PATH="$p"
        break
    fi
done

if [ -z "$NOVNC_PATH" ]; then
    NOVNC_PATH="/usr/share/novnc"
fi

echo "noVNC path: $NOVNC_PATH"
cd "$NOVNC_PATH"
websockify --web . ${NO_VNC_PORT} localhost:${VNC_PORT} &

echo "=== All services started ==="
echo "RDP (client):  port ${RDP_PORT}"
echo "noVNC (browser): port ${NO_VNC_PORT}"
echo "User:     ${RDP_USER}"
echo "Password: ${RDP_PASSWORD}"

tail -f /dev/null
