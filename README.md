# Free RDP — NoMachine + Bore Tunnel on Railway

Two Railway services working together for free remote desktop access from anywhere.

## Architecture

```
NoMachine Client → Railway TCP Proxy → bore server → Railway private network → desktop VM
```

## Deploy (2 Services)

### Step 1: Deploy Bore Server (tiny, ~5MB)

1. Railway → New Project → Deploy from GitHub Repo → same repo
2. Open service → **Settings → Build**
3. Set **Dockerfile Path** to: `bore-server/Dockerfile`
4. Service will auto-restart. Done. Note its **private hostname** (e.g., `bore-server.up.railway.app`)

### Step 2: Deploy Desktop VM

1. Same Railway project → New Service → Deploy from GitHub Repo → same repo
2. Open service → **Variables** tab, add:
   - `RDP_PASSWORD` = any password
   - `BORE_SERVER` = `<bore-server-service-name>.railway.internal` (the private network address)
   - `BORE_SECRET` = `railwayfree2026` (same as bore server)
3. **Settings → Networking → TCP Proxy** → port `8080` (for browser/noVNC backup)

### Step 3: Connect with NoMachine

1. Open **Deploy Logs** of the desktop service
2. Find the line:
   ```
   bore: listening at bore-server.railway.internal:XXXXX
   ```
3. Add a **TCP Proxy** on the **bore-server** service → port `7835`
4. In NoMachine client:
   ```
   Host: <bore-server>.proxy.rlwy.net
   Port: <assigned port>
   Protocol: NX
   User: user
   Password: <your RDP_PASSWORD>
   ```

## Access from Anywhere

| Method | How |
|--------|-----|
| **NoMachine client** | Connect via bore tunnel (above) |
| **Browser** | Open port 8080 TCP Proxy URL → noVNC |

## Cost

- Bore server: ~1MB RAM → nearly free
- Desktop VM: ~100MB RAM → $5 lasts ~25 days
- Both communicate via Railway private network → no egress charges

## Local Test

```bash
# Terminal 1: bore server
docker run --rm -p 7835:7835 bore-server

# Terminal 2: desktop
docker build -t free-rdp .
docker run --rm -e BORE_SERVER=host.docker.internal -p 8080:8080 free-rdp
```
