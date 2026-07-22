#!/bin/bash
set -e

RDP_PASSWORD="${RDP_PASSWORD:-password}"
RDP_USER="${RDP_USER:-user}"

echo "=== Setting up RDP user: ${RDP_USER} ==="

# Create user if not exists
if ! id "$RDP_USER" &>/dev/null; then
    useradd -m -s /bin/bash "$RDP_USER"
fi
echo "${RDP_USER}:${RDP_PASSWORD}" | chpasswd
usermod -aG sudo "$RDP_USER"

# Allow passwordless sudo for the user
echo "${RDP_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/"${RDP_USER}"

# Set root password
echo "root:${RDP_PASSWORD}" | chpasswd

# Fix xrdp startwm.sh
cat > /etc/xrdp/startwm.sh << 'WMEOF'
#!/bin/sh
if test -r /etc/profile; then
    . /etc/profile
fi
if test -r ~/.profile; then
    . ~/.profile
fi
test -x /etc/X11/Xsession && exec /etc/X11/Xsession
exec /bin/sh /etc/X11/Xsession
WMEOF
chmod 755 /etc/xrdp/startwm.sh

# Create .xsession for the user
echo "xfce4-session" > /home/${RDP_USER}/.xsession
chown ${RDP_USER}:${RDP_USER} /home/${RDP_USER}/.xsession

# Set up VNC password
mkdir -p /root/.vnc
echo "${RDP_PASSWORD}" | vncpasswd -f > /root/.vnc/passwd
chmod 600 /root/.vnc/passwd

# Create xstartup for VNC
cat > /root/.xstartup << 'XEOF'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export XDG_CURRENT_DESKTOP=XFCE
exec startxfce4
XEOF
chmod +x /root/.xstartup

echo "=== Starting services ==="

# Start VNC server on port 5901
vncserver :1 -geometry ${VNC_RESOLUTION} -depth 24 -localhost no &

# Start xrdp on port 3389
service xrdp start &

# Start noVNC on port 8080
cd /usr/share/novnc
websockify --web . ${NO_VNC_PORT} localhost:${VNC_PORT} &

echo "=== Services started ==="
echo "RDP:     port ${RDP_PORT}"
echo "noVNC:   port ${NO_VNC_PORT}"
echo "VNC:     port ${VNC_PORT}"
echo "User:    ${RDP_USER}"
echo "Password: ${RDP_PASSWORD}"

# Keep container running
tail -f /dev/null
