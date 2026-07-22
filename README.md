# Free RDP — Super Light Desktop on Railway

Zero-config deploy. Just connect and use.

## What You Get
- **fluxbox** window manager (tiny, fast)
- **Firefox ESR** (browser)
- **Thunar** (file manager)
- **xterm / mousepad** (terminal & editor)
- **RDP access** (Windows Remote Desktop, Remmina)
- **Browser access** (noVNC — works on phone too)
- Auto-generated password — no setup needed

## Deploy

1. Push this repo to GitHub
2. Railway → New Project → Deploy from GitHub Repo
3. **Done.** No variables, no config needed.

## Access

### Browser (noVNC)
Add a **TCP Proxy** → port `8080` → open the URL → click Connect

### RDP Client
Add a **TCP Proxy** → port `3389` → connect with any RDP app

**Find your password:** Railway → your service → **Deploy Logs** → look for `Password: xxxxxxxxxx`

## Local Test

```bash
docker build -t free-rdp .
docker run --rm -p 3389:3389 -p 8080:8080 free-rdp
```
