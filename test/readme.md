# 🛡️ 01. Network Security Layer

**Device:** Raspberry Pi Zero 2 W  
**OS:** Raspberry Pi OS Lite (64-bit)  
**IP:** Static (e.g., 192.168.1.5)

## 🧩 Split-Tunnel Architecture
This setup uses the "Split DNS" method to block ads without slowing down internet speed.

```mermaid
graph TD
    %% --- NODES (Standard shapes with standard text) ---
    Phone(Your Phone/Laptop)
    
    subgraph HomeNet [Home Network Environment]
        Router[WiFi Router Gateway]

        subgraph SecurityZone [Security Zone]
           PZ[("Pi Zero 2 W\n(DNS & VPN Guard)")]
        end

        subgraph MediaZone [Media Zone]
           P4[("Pi 4\n(NAS & Jellyfin)")]
        end
    end

    %% --- CONNECTIONS ---
    %% We use standard arrows but add text labels
    Phone == "1. DNS Query (Ad Check)" ==> PZ
    Phone == "2. Video Stream" ==> P4
    Phone -- "3. Normal Internet" --> Router
    
    Router -.-> PZ
    Router -.-> P4

    %% --- DIRECT STYLING (The safe way) ---
    %% Orange for Phone
    style Phone fill:#f57f17,stroke:#e65100,stroke-width:3px,color:white
    
    %% Green for Security (Pi Zero)
    style PZ fill:#43a047,stroke:#1b5e20,stroke-width:2px,color:white,stroke-dasharray: 5 5
    style SecurityZone fill:#e8f5e9,stroke:#a5d6a7,color:#1b5e20
    
    %% Purple for Media (Pi 4)
    style P4 fill:#7b1fa2,stroke:#4a148c,stroke-width:3px,color:white
    style MediaZone fill:#f3e5f5,stroke:#ce93d8,color:#4a148c
    
    %% Grey for Router
    style Router fill:#546e7a,stroke:#263238,stroke-width:2px,color:white
    style HomeNet fill:#eceff1,stroke:#cfd8dc,color:#455a64
```

## 🛠️ Installation Commands
```bash
# Install Pi-hole
curl -sSL [https://install.pi-hole.net](https://install.pi-hole.net) | bash

# Install Tailscale
curl -fsSL [https://tailscale.com/install.sh](https://tailscale.com/install.sh) | sh

# Install Log2Ram (Protect SD Card)
echo "deb [http://packages.azlux.fr/debian/](http://packages.azlux.fr/debian/) buster main" | sudo tee /etc/apt/sources.list.d/azlux.list
sudo apt install log2ram
```
