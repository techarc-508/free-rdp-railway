#!/bin/bash
set -e

RDP_PASSWORD="${RDP_PASSWORD:-password}"
RDP_USER="${RDP_USER:-user}"

echo "=== Setting up user: ${RDP_USER} ==="

# Set root password
echo "root:${RDP_PASSWORD}" | chpasswd

# Create user if not exists
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

# Create .xsession for the user
echo "xfce4-session" > /home/${RDP_USER}/.xsession
chown ${RDP_USER}:${RDP_USER} /home/${RDP_USER}/.xsession

echo "=== Starting services ==="

# Start Xvfb (virtual display)
Xvfb :1 -screen 0 ${VNC_RESOLUTION}x24 &
sleep 2

# Start x11vnc (VNC server on the virtual display)
x11vnc -display :1 -forever -shared -rfbport ${VNC_PORT} -nopw -xkb &
sleep 1

# Start xrdp
service xrdp start &

# Start noVNC (browser access)
cd /usr/share/novnc
websockify --web . ${NO_VNC_PORT} localhost:${VNC_PORT} &

echo "=== All services started ==="
echo "RDP (client):  port ${RDP_PORT}"
echo "noVNC (browser): port ${NO_VNC_PORT}"
echo "User:     ${RDP_USER}"
echo "Password: ${RDP_PASSWORD}"

# Keep container alive
tail -f /dev/null
