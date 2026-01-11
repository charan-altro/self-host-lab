# 🏠 Self-Hosted Home Lab

This repository documents a self-hosted home lab running on a **Raspberry Pi 4 (8GB)**. It features a secure, automated HTTPS setup using Traefik, Let's Encrypt, and Cloudflare DDNS to handle dynamic IPs from the ISP (Airtel).

## ️ Architecture & Security Flow

We use **Traefik** as the central entry point (Reverse Proxy) which automatically manages SSL certificates. Since our ISP provides a dynamic IP, a **DDNS script** ensures our domain always points to the correct home address.


```mermaid
flowchart LR
    %% --- GLOBAL STYLES (Cloudflare-like Aesthetic) ---
    classDef base fill:#fff,stroke:#333,stroke-width:1px,color:#333,font-family:sans-serif,rx:4,ry:4
    
    %% Specific Styles
    classDef user fill:#EBF8FF,stroke:#0051C3,stroke-width:2px,color:#0051C3
    classDef component fill:#fff,stroke:#F48120,stroke-width:2px,color:#333 %% Orange borders for active infrastructure
    classDef app fill:#F0F4F8,stroke:#00A9E0,stroke-width:1px,color:#333 %% Light blue apps
    classDef helper fill:#fff,stroke:#999,stroke-width:1px,stroke-dasharray: 4 4,color:#666 %% Dashed for scripts
    classDef cloud fill:none,stroke:#00A9E0,stroke-width:2px,stroke-dasharray: 8 6,color:#00A9E0

    %% --- NODES ---
    User(("💻 User")):::user

    subgraph Cloud ["☁️ Internet"]
        direction TB
        CF_DNS["Cloudflare DNS"]:::component
        LE["Let's Encrypt"]:::helper
    end

    subgraph Home ["🏠 Home Network"]
        Router["Router"]:::component
        
        subgraph Server ["Raspberry Pi 4"]
            direction TB
            Traefik["Traefik Proxy"]:::component
            DDNS["DDNS Script"]:::helper
            
            subgraph Apps ["Docker Apps"]
                %% Linking these invisible lines helps stack them neatly
                Homepage["Homepage"]:::app
                Jellyfin["Jellyfin"]:::app
                Nextcloud["Nextcloud"]:::app
                PiHole["Pi-hole"]:::app
                Tailscale["Tailscale"]:::app
            end
        end
    end

    %% --- MAIN TRAFFIC FLOW (Thick Orange Lines) ---
    User ==> |"HTTPS"| CF_DNS
    CF_DNS ==> |"Home IP"| Router
    Router ==> |"Port 443"| Traefik
    Traefik ==> |"Route"| Homepage
    
    %% --- INTERNAL APP LINKS (Subtle) ---
    %% We link Traefik to just the top app to keep the line straight, 
    %% then use invisible links or light links for the rest to avoid "Spaghetti"
    Traefik --> Jellyfin
    Traefik --> Nextcloud
    Traefik --> PiHole
    Traefik --> Tailscale

    %% --- MANAGEMENT LINKS (Dashed/Subtle) ---
    DDNS -.-> |"Update IP"| CF_DNS
    Traefik -.-> |"Get Certs"| LE

    %% --- STYLING ADJUSTMENTS ---
    %% Style the main layout boxes
    class Cloud cloud
    class Home,Server cloud

    %% Force the main path to be Orange and Thick
    linkStyle 0,1,2,3 stroke:#F48120,stroke-width:3px,fill:none
    
    %% Make the app connections thinner and blue
    linkStyle 4,5,6,7 stroke:#00A9E0,stroke-width:1px,fill:none
    
    %% Make management links gray
    linkStyle 8,9 stroke:#999,stroke-width:1px,stroke-dasharray: 4 4,fill:none
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
