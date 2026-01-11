# 🏠 Self-Hosted Home Lab

This repository documents a self-hosted home lab running on a **Raspberry Pi 4 (8GB)**. It features a secure, automated HTTPS setup using Traefik, Let's Encrypt, and Cloudflare DDNS to handle dynamic IPs from the ISP (Airtel).

## ️ Architecture & Security Flow

We use **Traefik** as the central entry point (Reverse Proxy) which automatically manages SSL certificates. Since our ISP provides a dynamic IP, a **DDNS script** ensures our domain always points to the correct home address.


```mermaid
flowchart LR
    %% --- THEME SETTINGS ---
    %% Force white backgrounds and dark text for a "Document" look
    classDef base fill:#ffffff,stroke:#D1D5DB,stroke-width:1px,color:#374151,font-family:sans-serif,rx:4,ry:4
    
    %% Specific Colors based on your reference image
    classDef user fill:#EFF6FF,stroke:#2563EB,stroke-width:2px,color:#1E3A8A %% Blue Client
    classDef orangeBox fill:#ffffff,stroke:#F97316,stroke-width:2px,color:#C2410C %% Orange/Important
    classDef blueBox fill:#F8FAFC,stroke:#3B82F6,stroke-width:1px,color:#1E3A8A %% Blue/Apps
    classDef dashedBox fill:#ffffff,stroke:#9CA3AF,stroke-width:2px,stroke-dasharray: 6 4,color:#6B7280 %% Dashed Containers
    
    %% --- GRAPH STRUCTURE ---
    
    %% 1. The Client
    User(💻 User):::user

    %% 2. The Internet Layer (Dashed Container)
    subgraph Internet ["☁️ Internet / Cloudflare"]
        direction LR
        DNS["Cloudflare DNS"]:::base
        LetsEncrypt["Let's Encrypt"]:::base
    end

    %% 3. The Home Network (Large Blue Container)
    subgraph Home ["🏠 Home Network"]
        direction LR
        Router["Router"]:::orangeBox
        
        %% 4. The Server (Orange Container)
        subgraph Pi ["Raspberry Pi 4 Server"]
            direction LR
            Traefik["Traefik Proxy"]:::orangeBox
            DDNS["DDNS Script"]:::base
            
            %% 5. Apps (Compact Stack)
            subgraph Apps ["🐳 Docker Apps"]
                direction TB
                Homepage["Homepage"]:::blueBox
                Media["Jellyfin"]:::blueBox
                Files["Nextcloud"]:::blueBox
                Network["Pi-hole & VPN"]:::blueBox
            end
        end
    end

    %% --- CONNECTIONS (Straight & Clean) ---
    %% Main "Golden Path" (Thick Orange)
    User ==>|HTTPS| DNS
    DNS ==>|Home IP| Router
    Router ==>|Port 443| Traefik
    Traefik ==>|Route| Apps

    %% Secondary Helper Lines (Dashed Gray)
    DDNS -.-o|Update IP| DNS
    Traefik -.-o|Certificates| LetsEncrypt

    %% --- STYLING THE CONTAINERS ---
    class Internet dashedBox
    class Home dashedBox
    class Pi dashedBox
    class Apps base

    %% --- COLORING THE LINES ---
    %% 0,1,2,3 are the main data path (Orange)
    linkStyle 0,1,2,3 stroke:#F97316,stroke-width:3px,fill:none
    %% 4,5 are helper lines (Gray)
    linkStyle 4,5 stroke:#9CA3AF,stroke-width:1px,stroke-dasharray: 5 5
```

## 🌐 Connectivity Logic

### 1. Dynamic DNS (DDNS)
**Problem:** Airtel Broadband changes the Public IP address frequently.
**Solution:** We use the [Cloudflare DDNS Updater](https://github.com/K0p1-Git/cloudflare-ddns-updater) script.
- **Function:** It runs periodically to check the current Public IP.
- **Action:** If the IP has changed, it updates the `A` records in Cloudflare DNS via API.
- **Result:** `*.example.com` always resolves to the home network.

### 2. Reverse Proxy & HTTPS (Traefik)
**Role:** Secure Gateway.
- **Traefik** listens on ports 80 and 443.
- **Let's Encrypt Integration:** Traefik automatically communicates with Let's Encrypt to generate and renew valid SSL certificates for all subdomains.
- **Force HTTPS:** All HTTP (Port 80) traffic is automatically redirected to HTTPS (Port 443).

## 🛠️ Hardware & Software

| Device | Role | Key Services |
|--------|------|--------------|
| **Raspberry Pi 4 (8GB)** | All-in-One Server | Docker, Traefik, Jellyfin, Nextcloud, DDNS Script |
