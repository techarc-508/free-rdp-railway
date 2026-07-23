# Free RDP — Ultra Light Desktop + Bore Tunnel

Zero-config deploy. Works on phone too.

## What You Get
- **fluxbox** window manager (tiny, fast)
- **Firefox ESR** not included (add later via terminal to save space)
- **xterm** terminal
- **Bore tunnel** — public URL for browser access (no Railway TCP proxy needed)
- **RDP access** — for Windows Remote Desktop
- **Auto password** — check deploy logs

## Deploy

1. Push repo to GitHub
2. Railway → New Project → Deploy from GitHub Repo
3. Done. No config needed.

## Access

### Browser (Recommended)
Check **Deploy Logs** for the bore URL:
```
Bore: bore.pub:XXXXX
```
Open `http://bore.pub:XXXXX` in any browser.

### RDP Client
Add TCP Proxy → port `3389`

## Install Apps After Deploy
Open terminal in the desktop:
```bash
sudo apt update && sudo apt install -y firefox-esr thunar mousepad nano htop wget curl git
```

## Resource Usage
- Fluxbox: ~30MB RAM idle
- Total: ~80-120MB RAM
- $5 trial lasts ~20-25 days at this usage

## Local Test
```bash
docker build -t free-rdp .
docker run --rm -p 8080:8080 -p 3389:3389 free-rdp
```
