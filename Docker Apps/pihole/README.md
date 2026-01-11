# Pi-hole

A DNS sinkhole that protects your devices from unwanted content, without installing any client-side software.

## 🚀 Solution Architecture

This diagram illustrates how Pi-hole filters DNS requests to block ads and trackers across your network.

```mermaid
graph TD
    subgraph "Home Network"
        Client(Laptop/Phone) -- "1. DNS Request" --> Pihole
        Router[WiFi Router] -- "DHCP/DNS Config" --> Client
    end

    subgraph "Docker Host"
        Pihole[("Pi-hole Container")]
        Pihole -- "2. Filter against Ad Lists" --> GravityDB((Gravity DB))
        Pihole -- "3. Forward Allowed Query" --> UpstreamDNS(Upstream DNS Server)
        Pihole -- "4. Return 0.0.0.0 for Blocked Query" --> Client
        Admin(You) -- "Web Interface" --> Pihole
    end

    style Pihole fill:#43a047,stroke:#1b5e20,stroke-width:2px,color:white
    style Client fill:#f57f17,stroke:#e65100,stroke-width:2px,color:white
    style Router fill:#546e7a,stroke:#263238,stroke-width:2px,color:white
    style Admin fill:#0277bd,stroke:#01579b,stroke-width:2px,color:white
```

## 🛠️ Setup

This Pi-hole instance is managed via Docker Compose.

1.  **Environment Variables:** Create a `.env` file in this directory with the following content:
    ```env
    PIHOLE_PASSWORD=your_admin_password
    ```
2.  **Start the container:**
    ```bash
    docker-compose up -d
    ```
3.  **Configure your network:** Point your router's DNS settings to the IP address of the Docker host.
