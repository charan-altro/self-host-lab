# 🏠 Self-Hosted Home Lab

This repository documents a self-hosted home lab running on a **Raspberry Pi 4 (8GB)**. It features a secure, automated HTTPS setup using Traefik, Let's Encrypt, and Cloudflare DDNS to handle dynamic IPs from the ISP (Airtel).

## ️ Architecture & Security Flow

We use **Traefik** as the central entry point (Reverse Proxy) which automatically manages SSL certificates. Since our ISP provides a dynamic IP, a **DDNS script** ensures our domain always points to the correct home address.


```mermaid
%%{init: {
  'theme': 'base',
  'themeVariables': {
    'background': '#F5F7FA',
    'primaryTextColor': '#1F2937',
    'lineColor': '#64748B',
    'fontSize': '14px'
  },
  'flowchart': { 'rankSpacing': 20, 'nodeSpacing': 20 }
}}%%
flowchart LR
    %% --- STYLES ---
    classDef base fill:#FFFFFF,stroke:#CBD5E1,stroke-width:1px,color:#1F2937,rx:4,ry:4,shadow:true
    classDef script fill:#F8FAFC,stroke:#2563EB,stroke-width:1px,color:#1E3A8A,rx:4,ry:4,font-family:monospace,align:left
    classDef cloud fill:#FFFFFF,stroke:#EA580C,stroke-width:2px,color:#1F2937,rx:4,ry:4,shadow:true

    %% --- STRUCTURE ---
    subgraph Maintenance ["🛠️ DDNS Synchronization Loop"]
        direction LR
        
        %% RASPBERRY PI SIDE
        subgraph Pi ["Raspberry Pi 4"]
            direction TB
            DDNS_Script["🐍 <b>DDNS Script</b>
            ──────────────
            1. Check Public IP
            2. Compare with DNS
            3. If Changed: Update"]:::script
        end

        %% CLOUDFLARE SIDE
        subgraph Cloud ["Cloudflare Cloud"]
            direction TB
            API["☁️ <b>Cloudflare API</b>
            ──────────────
            Updates 'A' Record
            points to New IP"]:::cloud
        end
    end

    %% --- LOGIC FLOW ---
    DDNS_Script ==>|"Periodic Check (Cron)"| API
    API -.->|"Confirm Update"| DDNS_Script

    %% --- STYLES ---
    class Maintenance masterZone
    
    %% Styles
    classDef masterZone fill:#F5F7FA,stroke:#E2E8F0,stroke-width:1px,rx:10,ry:10,color:#334155
    linkStyle 0 stroke:#2563EB,stroke-width:3px
    linkStyle 1 stroke:#94A3B8,stroke-width:2px,stroke-dasharray: 4 4
```

```mermaid
%%{init: {
  'theme': 'base',
  'themeVariables': {
    'background': '#F5F7FA',
    'primaryTextColor': '#1F2937',
    'lineColor': '#64748B',
    'fontSize': '14px'
  },
  'flowchart': { 'rankSpacing': 15, 'nodeSpacing': 15 }
}}%%
flowchart LR
    %% --- STYLES ---
    classDef client fill:#FFFFFF,stroke:#2563EB,stroke-width:2px,color:#1E3A8A,rx:4,ry:4,font-weight:bold,shadow:true
    classDef netStack fill:#FFFFFF,stroke:#EA580C,stroke-width:2px,color:#1F2937,rx:4,ry:4,shadow:true,align:center
    classDef appStack fill:#F8FAFC,stroke:#2563EB,stroke-width:1px,color:#1E293B,rx:4,ry:4,align:left,font-family:monospace
    
    %% --- STRUCTURE ---
    subgraph Traffic ["🌐 Secure Data Traffic Flow"]
        direction LR

        %% 1. USER
        User["💻 <b>User / Client</b>
        <i>(External Request)</i>"]:::client

        %% 2. NETWORK STACK (Forced Vertical)
        subgraph NetLayer ["Network Path"]
            Stack["🌐 <b>Cloudflare DNS</b>
            ⬇️ <i>(Resolve IP)</i>
            🏠 <b>Home Router</b>
            ⬇️ <i>(Port Forward 443)</i>
            🚦 <b>Traefik Proxy</b>"]:::netStack
        end

        %% 3. APPS
        subgraph Server ["Docker Host"]
            Apps["🐳 <b>Docker Apps</b>
            ─────────────
            🖥️ Dashboard
            🎬 Media
            📁 Storage
            🛡️ DNS/VPN"]:::appStack
        end
    end

    %% --- CONNECTIONS ---
    User ==>|"HTTPS (443)"| Stack
    Stack ==>|"Secure Route"| Apps

    %% --- STYLES ---
    linkStyle 0,1 stroke:#EA580C,stroke-width:3px
    
    %% Container Style
    classDef masterZone fill:#F5F7FA,stroke:#E2E8F0,stroke-width:1px,rx:10,ry:10,color:#334155
    class Traffic masterZone
    class NetLayer,Server innerZone
    classDef innerZone fill:#FFFFFF,stroke:#94A3B8,stroke-width:1px,stroke-dasharray: 6 4
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
