# Free RDP — Access Your Local VM from Anywhere

Expose your local Linux Mint VM to the internet via Railway + bore tunnel.
Connect with NoMachine from any network.

## How It Works

```
[NoMachine Client (phone/anywhere)]
    → [Railway TCP Proxy]
        → [bore server on Railway]
            → [bore tunnel to your VM]
                → [NoMachine on your Linux Mint VM]
                    → [Your desktop]
```

## Setup (3 Steps)

### Step 1: Deploy Bore Server on Railway

1. Push this repo to GitHub
2. Railway → New Project → Deploy from GitHub Repo
3. Open service → **Settings → Build**
4. Set **Dockerfile Path** to: `bore-server/Dockerfile`
5. Wait for deploy. Note the service name (e.g., `bore-server`)

### Step 2: Install Bore Client on Your VM

Run on your Linux Mint VM:
```bash
bash setup-bore-client.sh
```

### Step 3: Start the Tunnel

```bash
bore local 4000 --to bore-server.railway.internal:7835 --secret railwayfree2026
```

Replace `bore-server.railway.internal` with your bore server's Railway private address.

### Step 4: Connect from Anywhere

1. Railway bore-server → **Settings → Networking → TCP Proxy** → port `7835`
2. Note the TCP Proxy hostname and port
3. NoMachine client:
   ```
   Host: <bore-server>.proxy.rlwy.net
   Port: <TCP proxy port>
   Protocol: NX
   User: your Linux username
   Password: your Linux password
   ```

## Your VM Info

| Item | Value |
|------|-------|
| OS | Linux Mint 22.3 (Zena) |
| IP | 192.168.0.200 |
| NoMachine | 9.8.2 (running) |
| NoMachine Port | 4000 |
| Display Manager | LightDM |

## Files

| File | Purpose |
|------|---------|
| `bore-server/Dockerfile` | Bore relay server (deploy on Railway) |
| `setup-bore-client.sh` | Install bore client (run on your VM) |
