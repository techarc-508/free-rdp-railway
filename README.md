# Free RDP - Debian XFCE Desktop on Railway

A lightweight Debian XFCE desktop you can access from any browser or RDP client, hosted on Railway.

## What's Included

- **Debian bookworm-slim** base (minimal footprint)
- **XFCE4** lightweight desktop environment
- **xrdp** — connect with any RDP client (Windows Remote Desktop, Microsoft RDP, Remmina, etc.)
- **noVNC** — access the desktop directly in your browser
- **VNC server** — for VNC client connections

## Ports

| Service | Port | Description |
|---------|------|-------------|
| xrdp    | 3389 | RDP client connections |
| noVNC   | 8080 | Browser-based desktop access |
| VNC     | 5901 | Direct VNC connections |

## Deploy to Railway

### Step 1: Push to GitHub

```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git push -u origin main
```

### Step 2: Create Railway Project

1. Go to [railway.app](https://railway.app)
2. Click **New Project** → **Deploy from GitHub Repo**
3. Select your repository

### Step 3: Set Environment Variables

In the Railway dashboard, go to your service → **Variables** tab and add:

| Variable | Required | Example | Description |
|----------|----------|---------|-------------|
| `RDP_PASSWORD` | Yes | `MyStr0ngP@ss` | Desktop login password (min 8 chars) |
| `RDP_USER` | No | `user` | Linux username (default: `user`) |
| `VNC_RESOLUTION` | No | `1920x1080` | Screen resolution (default: `1280x720`) |

### Step 4: Add TCP Proxy

1. Go to **Settings** → **Networking**
2. Add a **TCP Proxy** targeting internal port `3389`
3. Note the hostname and port shown (e.g., `roundhouse.proxy.rlwy.net:25341`)

### Step 5: Add noVNC Proxy (Browser Access)

1. Add another **TCP Proxy** targeting internal port `8080`
2. Use the generated URL to access the desktop in your browser

## Connect

### Via RDP Client (Recommended)

1. Open your RDP client (Remote Desktop, Remmina, etc.)
2. Enter the Railway TCP Proxy address: `hostname.proxy.rlwy.net:port`
3. Login with your username and password

### Via Browser (noVNC)

1. Open the noVNC TCP Proxy URL in your browser
2. Click **Connect**
3. Enter the VNC password

## Local Testing

```bash
docker build -t free-rdp .
docker run --rm -p 3389:3389 -p 8080:8080 \
  -e RDP_PASSWORD='TestPass123' \
  free-rdp
```

Then connect to `localhost:3389` with your RDP client, or open `http://localhost:8080` in your browser.

## Persistent Storage

To keep files between redeployments, add a **Railway Volume** mounted at `/home/user` (or your custom `RDP_USER` home directory).

## Tips

- Use a strong random password — anyone with the TCP Proxy address can reach the login screen
- Minimum recommended: 1 vCPU + 2 GB RAM
- The RDP certificate is self-signed — accept the warning if the hostname matches your Railway TCP Proxy
