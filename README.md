# 🏠 Self-Hosted Home Lab

This repository documents a self-hosted home lab running on a **Raspberry Pi 4 (8GB)**. It features a secure, automated HTTPS setup using Traefik, Let's Encrypt, and Cloudflare DDNS to handle dynamic IPs from the ISP (Airtel).

## ️ Architecture & Security Flow

We use **Traefik** as the central entry point (Reverse Proxy) which automatically manages SSL certificates. Since our ISP provides a dynamic IP, a **DDNS script** ensures our domain always points to the correct home address.


```mermaid
flowchart TB
    %% --- GLOBAL STYLES ---
    %% 1. Basic Nodes (White Background, Sharp Corners)
    classDef base fill:#fff,stroke:#333,stroke-width:1px,color:#333,rx:0,ry:0,font-family:Arial
    
    %% 2. The Client (Blue Outline)
    classDef client fill:#fff,stroke:#0051C3,stroke-width:2px,color:#0051C3,rx:5,ry:5
    
    %% 3. The Network Components (Orange Theme)
    classDef transit fill:#fff,stroke:#F48120,stroke-width:2px,color:#2c2c2c,rx:0,ry:0
    
    %% 4. The Docker List Box (Blue Theme, Left Aligned Text)
    classDef listBox fill:#fff,stroke:#00A9E0,stroke-width:2px,color:#2c2c2c,rx:0,ry:0,align:left

    %% --- CONTAINER STYLES ---
    %% Dashed Orange for Network
    classDef networkContainer fill:#fff,stroke:#F48120,stroke-width:2px,stroke-dasharray: 8 6,color:#F48120
    %% Solid Blue for Server
    classDef serverContainer fill:#EBF8FF,stroke:#00A9E0,stroke-width:2px,color:#0051C3

    %% --- DIAGRAM STRUCTURE ---

    %% 1. TOP: Client & Helper
    User["💻 Client / User"]:::client
    DDNS["🔄 DDNS Updater"]:::base

    %% 2. MIDDLE: Routing Layer
    subgraph Routing ["☁️ Ingress & Routing Layer"]
        direction TB
        DNS["🌐 Cloudflare DNS"]:::transit
        Router["🏠 Home Router"]:::transit
        Traefik["🚦 Traefik Proxy"]:::transit
    end

    %% 3. BOTTOM: Server & App List
    subgraph Server ["Raspberry Pi 4 - Docker Host"]
        direction TB
        
        %% This is the Single Box with the List you requested
        DockerList["🐳 Docker Containers
        ________________________
        🖥️ Homepage Dashboard
        🎬 Jellyfin Media
        📁 Nextcloud Storage
        🛡️ Pi-hole DNS
        🔒 Tailscale VPN"]:::listBox
    end

    %% --- CONNECTIONS ---
    
    %% Main Flow (Thick Orange Lines)
    User ==>|HTTPS Request| DNS
    DNS ==>|Resolve IP| Router
    Router ==>|Port 443| Traefik
    Traefik ==>|Route| DockerList

    %% Helper Lines (Dashed Gray)
    DDNS -.-o|Update API| DNS

    %% --- APPLY STYLES ---
    class Routing networkContainer
    class Server serverContainer

    %% Link Styles: 0-3 are Orange (Active Path), 4 is Gray (Helper)
    linkStyle 0,1,2,3 stroke:#F48120,stroke-width:3px,fill:none
    linkStyle 4 stroke:#999,stroke-width:1px,stroke-dasharray: 4 4
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
