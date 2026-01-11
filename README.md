# 🏠 Self-Hosted Home Lab

This repository documents a self-hosted home lab running on a **Raspberry Pi 4 (8GB)**. It features a secure, automated HTTPS setup using Traefik, Let's Encrypt, and Cloudflare DDNS to handle dynamic IPs from the ISP (Airtel).

## ️ Architecture & Security Flow

We use **Traefik** as the central entry point (Reverse Proxy) which automatically manages SSL certificates. Since our ISP provides a dynamic IP, a **DDNS script** ensures our domain always points to the correct home address.


```mermaid
flowchart LR
    %% --- THEME: CLOUDFLARE STYLE ---
    %% 1. Basic White Node
    classDef base fill:#fff,stroke:#666,stroke-width:1px,color:#333,rx:5,ry:5
    
    %% 2. The "Client" and "Destination" (Blue Theme)
    classDef blueNode fill:#EBF8FF,stroke:#00A9E0,stroke-width:2px,color:#0051C3
    
    %% 3. The "Network Middle" (Orange Theme - Active Path)
    classDef orangeNode fill:#fff,stroke:#F48120,stroke-width:3px,color:#333
    
    %% 4. Containers/Groups (Dashed Orange or Blue)
    classDef container fill:#fff,stroke:#F48120,stroke-width:2px,stroke-dasharray: 5 5,color:#F48120,rx:10,ry:10
    classDef homeContainer fill:#F9FAFB,stroke:#9CA3AF,stroke-width:2px,stroke-dasharray: 8 8,color:#6B7280,rx:10,ry:10

    %% --- STRUCTURE ---

    %% A. The User (Start)
    User("💻 User / Client"):::blueNode

    %% B. The Network (Middle Section)
    subgraph Network ["☁️ Internet & Routing"]
        direction LR
        DNS["Cloudflare DNS"]:::orangeNode
        Router["🏠 Home Router"]:::orangeNode
        Traefik["🚦 Traefik Proxy"]:::orangeNode
    end

    %% C. The Destination (End)
    subgraph Server ["Raspberry Pi 4"]
        direction TB
        %% This invisible node helps align the title or structure if needed
        
        subgraph Apps ["🐳 Docker Service Stack"]
            direction TB
            %% Stacking these looks like the 'Server Rack' in your reference image
            Homepage["Homepage Dashboard"]:::blueNode
            Jellyfin["🎬 Jellyfin Media"]:::blueNode
            Nextcloud["📁 Nextcloud Storage"]:::blueNode
            PiHole["🛡️ Pi-hole & VPN"]:::blueNode
        end
        
        %% Sidecar Scripts (Helper)
        DDNS("🔄 DDNS Script"):::base
    end

    %% --- CONNECTIONS ---
    
    %% 1. The "Golden Path" (Thick Orange Line) represents the Request Flow
    User ==>|HTTPS Request| DNS
    DNS ==>|Home Public IP| Router
    Router ==>|Port 443| Traefik
    Traefik ==>|Route| Apps

    %% 2. Maintenance Links (Dotted/Grey)
    DDNS -.-o|Update IP| DNS

    %% --- STYLING APPLICATION ---
    class Network container
    class Server homeContainer
    
    %% Style the Main Flow lines (0,1,2,3) to be Orange and Thick
    linkStyle 0,1,2,3 stroke:#F48120,stroke-width:4px,fill:none
    
    %% Style the Helper line (4) to be Grey
    linkStyle 4 stroke:#999,stroke-width:2px,stroke-dasharray: 4 4
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
