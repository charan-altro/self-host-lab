# 🏠 Self-Hosted Home Lab

This repository documents a self-hosted home lab running on a **Raspberry Pi 4 (8GB)**. It features a secure, automated HTTPS setup using Traefik, Let's Encrypt, and Cloudflare DDNS to handle dynamic IPs from the ISP (Airtel).

## ️ Architecture & Security Flow

We use **Traefik** as the central entry point (Reverse Proxy) which automatically manages SSL certificates. Since our ISP provides a dynamic IP, a **DDNS script** ensures our domain always points to the correct home address.


```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'background': '#ffffff', 'mainBkg': '#ffffff', 'primaryTextColor': '#1e293b'}}}%%
flowchart TB
    %% --- GLOBAL PROFESSIONAL STYLES ---
    %% 1. Basic Node Style (Clean white, dark gray text, subtle rounded corners)
    classDef base fill:#ffffff,stroke:#CBD5E1,stroke-width:1px,color:#1E293B,rx:4,ry:4,font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif

    %% 2. Client/Endpoint Style (Deep Corporate Blue)
    classDef client fill:#ffffff,stroke:#1E3A8A,stroke-width:2px,color:#1E3A8A,rx:4,ry:4,font-weight:bold

    %% 3. Active Routing Path Style (Vibrant Professional Orange)
    classDef transit fill:#ffffff,stroke:#EA580C,stroke-width:2px,color:#1E293B,rx:4,ry:4

    %% 4. The App List Box (Subtle Off-White fill to distinguish content)
    classDef listBox fill:#F8FAFC,stroke:#1E3A8A,stroke-width:1px,color:#1E293B,rx:4,ry:4,align:left

    %% --- CONTAINER STYLES (Cool Gray for Professional Zones) ---
    %% Dashed Gray for Network Zone
    classDef networkContainer fill:#ffffff,stroke:#64748B,stroke-width:2px,stroke-dasharray: 6 4,color:#64748B
    %% Solid Gray for Server Zone
    classDef serverContainer fill:#F1F5F9,stroke:#64748B,stroke-width:2px,color:#64748B

    %% --- DIAGRAM STRUCTURE ---

    %% 1. TOP: Inputs
    User["💻 Client / User"]:::client
    DDNS["🔄 DDNS Updater script"]:::base

    %% 2. MIDDLE: Routing Zone
    subgraph Routing ["☁️ Ingress & Routing Layer"]
        direction TB
        DNS["🌐 Cloudflare DNS"]:::transit
        Router["🏠 Home Router"]:::transit
        Traefik["🚦 Traefik Reverse Proxy"]:::transit
    end

    %% 3. BOTTOM: Server Zone
    subgraph Server ["Raspberry Pi 4 - Docker Host"]
        direction TB
        %% Compacted List Box with refined formatting
        DockerList["🐳 **Docker Service Stack**
        Isolating applications via containerization.
        ____________________________________
        🖥️ **Homepage** | Dashboard
        🎬 **Jellyfin** | Media Server
        📁 **Nextcloud** | Secure Storage
        🛡️ **Pi-hole** | DNS AdBlocking
        🔒 **Tailscale** | Mesh VPN"]:::listBox
    end

    %% --- CONNECTIONS (High Contrast) ---
    
    %% Main Active Flow (Thick Orange)
    User ==>|HTTPS Request (443)| DNS
    DNS ==>|Resolve Public IP| Router
    Router ==>|Port Forward| Traefik
    Traefik ==>|Secure Route| DockerList

    %% Maintenance Flow (Dashed Gray)
    DDNS -.-o|API Update| DNS

    %% --- APPLY STYLES ---
    class Routing networkContainer
    class Server serverContainer

    %% Link Styles: Orange for active path, Gray for maintenance
    linkStyle 0,1,2,3 stroke:#EA580C,stroke-width:3px,fill:none
    linkStyle 4 stroke:#94A3B8,stroke-width:1px,stroke-dasharray: 4 4
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
