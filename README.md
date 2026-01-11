# 🏠 Self-Hosted Home Lab

This repository documents a self-hosted home lab running on Raspberry Pi, secured and accessible via Cloudflare.

## 🌐 Cloudflare Integration

We use a hybrid approach for connectivity to ensure secure and reliable access to multiple applications.

### 1. Cloudflare Tunnel (The "Agent")
Instead of opening ports on the router, we run the **Cloudflare Agent (`cloudflared`)** on the Raspberry Pi.
- **How it works**: It creates an outbound encrypted tunnel to Cloudflare's edge network.
- **DNS Management**: The tunnel automatically maps subdomains (e.g., `jellyfin.example.com`) to local Docker containers.
- **Security**: Hides the real home IP address and blocks direct attacks.

### 2. Dynamic DNS (DDNS)
We use a **DDNS Script** as a backup connectivity layer.
- **Purpose**: Automatically detects when the ISP changes the home Public IP.
- **Action**: Updates the Cloudflare DNS `A` record via API.
- **Usage**: Useful for services that require direct IP connection (like VPNs or SSH) bypassing the HTTP tunnel.

## 🏗️ Architecture Diagram

```mermaid
graph TD
    User((User))
    CF{Cloudflare Network}
    
    subgraph Home_Network [Raspberry Pi Lab]
        Agent[Cloudflare Tunnel<br/>(cloudflared)]
        DDNS[DDNS Script]
        
        subgraph Apps [Hosted Apps]
            Jellyfin[Jellyfin Media]
            Dash[Dashboard]
            PiHole[Pi-hole DNS]
        end
    end

    User -->|https://app.domain.com| CF
    CF <-->|Encrypted Tunnel| Agent
    Agent -->|Localhost:8096| Jellyfin
    Agent -->|Localhost:3000| Dash
    
    DDNS -.->|Update Public IP| CF
```

## 🛠️ Hardware & Software

| Device | Role | Key Services |
|--------|------|--------------|
| **Raspberry Pi 4** | Application Host | Docker, Jellyfin, Cloudflare Tunnel |
| **Pi Zero 2 W** | Network Utility | Pi-hole, DDNS Script |
