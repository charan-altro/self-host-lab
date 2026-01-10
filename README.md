# self-host-lab
Infrastructure as Code for a self-hosted home lab using Raspberry Pi 4 (Media/NAS) and Zero 2 W (Network Security). Features Pi-hole, Tailscale, Jellyfin, etc and Docker Compose workflows.

# 1. Create the main repository folder
mkdir self-host-lab
cd self-host-lab

# 2. Initialize Git
git init

# 3. Create the Service Folders
mkdir 01-network-security
mkdir 02-media-nas
mkdir 03-dashboard

# ==========================================
# 4. Create Root README with Global Diagram
# ==========================================
cat > README.md <<EOF
# 🏠 self-host-lab

Documentation for my personal home infrastructure running on Raspberry Pi.

## 🏗 System Architecture
\`\`\`mermaid
graph TD
    %% Global Styling
    classDef mobile fill:#f57f17,stroke:#e65100,stroke-width:2px,color:white
    classDef security fill:#43a047,stroke:#1b5e20,stroke-width:2px,color:white,stroke-dasharray: 5 5
    classDef media fill:#7b1fa2,stroke:#4a148c,stroke-width:2px,color:white
    
    Phone(My Phone/Laptop):::mobile
    
    subgraph Home [Home Network]
        PZ(<b>Pi Zero 2 W</b><br/>Network Guard):::security
        P4(<b>Pi 4</b><br/>Media & NAS):::media
    end

    Phone -- "DNS (Ads)" --> PZ
    Phone -- "Stream" --> P4
    PZ -.-> P4
\`\`\`

## 📂 Modules
- **[01-network-security](./01-network-security)**: Pi-hole & Tailscale (Pi Zero 2 W)
- **[02-media-nas](./02-media-nas)**: Jellyfin & Storage (Pi 4)
- **[03-dashboard](./03-dashboard)**: Status Homepage
EOF

# ==========================================
# 5. Create Network Security README (Pi Zero)
# ==========================================
cat > 01-network-security/README.md <<EOF
# 🛡️ 01. Network Security Layer

**Device:** Raspberry Pi Zero 2 W  
**Role:** Ad-blocking & VPN Entry

## 🧩 Split-Tunnel Architecture
\`\`\`mermaid
graph TD
    classDef dns fill:#c62828,stroke:#b71c1c,color:white
    classDef net fill:#1565c0,stroke:#0d47a1,color:white

    Phone[Phone 5G]
    PiZero[Pi Zero 2 W]:::dns
    Internet[The Internet]:::net

    Phone -- "1. Heavy Data (Netflix)" --> Internet
    Phone -- "2. DNS Query (Ad Check)" --> PiZero
    PiZero -- "Block/Allow" --> Phone
\`\`\`
EOF

# ==========================================
# 6. Create Media README + Docker Compose (Pi 4)
# ==========================================
cat > 02-media-nas/README.md <<EOF
# 🎬 02. Media & NAS Layer

**Device:** Raspberry Pi 4 Model B  
**Role:** Media Streaming & File Storage

## 📼 Media Flow
\`\`\`mermaid
graph LR
    classDef hdd fill:#fbc02d,stroke:#f57f17,color:black
    classDef app fill:#8e24aa,stroke:#4a148c,color:white

    User[User Device]
    Jellyfin[Jellyfin Container]:::app
    HDD[(USB Hard Drive)]:::hdd

    User -- "Request Movie" --> Jellyfin
    Jellyfin -- "Read File" --> HDD
    Jellyfin -- "Stream Video" --> User
\`\`\`
EOF

# Create the actual docker-compose file for Jellyfin
cat > 02-media-nas/docker-compose.yml <<EOF
services:
  jellyfin:
    image: jellyfin/jellyfin
    container_name: jellyfin
    user: 1000:1000
    network_mode: "host"
    volumes:
      - ./config:/config
      - ./cache:/cache
      - /mnt/media:/media
    restart: unless-stopped
EOF

# ==========================================
# 7. Create Dashboard README
# ==========================================
cat > 03-dashboard/README.md <<EOF
# 📊 03. Dashboard
**Software:** Homepage / Dashy
**Goal:** Monitor uptime of Pi Zero and Pi 4.
EOF

# 8. Create a .gitignore
echo ".DS_Store" > .gitignore
echo ".env" >> .gitignore

echo "✅ Repository 'self-host-lab' created successfully!"
