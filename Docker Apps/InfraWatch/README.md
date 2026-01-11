# InfraWatch - Infrastructure Monitoring

A comprehensive monitoring solution that combines the strengths of Netdata and Beszel. Netdata provides high-fidelity, real-time metrics and visualizations for your entire infrastructure, while Beszel offers a lightweight, event-driven approach to container monitoring. Together, they provide a complete picture of your system's health and performance, from low-level system metrics to high-level container events.

## 🚀 Solution Architecture

This diagram shows the architecture of the monitoring stack, with Netdata for metrics and Beszel for container events.

```mermaid
graph TD
    subgraph "User Interaction"
        User(You) -- "Views Dashboards" --> Traefik
    end

    subgraph "Docker Host"
        Traefik[("Traefik")] -- "netdata.jedarabale.space" --> Netdata[("Netdata")]
        Traefik -- "beszel.jedarabale.space" --> Beszel[("Beszel Hub")]

        Netdata -- "Collects System Metrics" --> HostOS((Host OS))
        Netdata -- "Collects Container Metrics" --> DockerSocket((/var/run/docker.sock))
        
        BeszelAgent[("Beszel Agent")] -- "Sends Metrics" --> Beszel
        BeszelAgent -- "Collects Container Events" --> DockerSocket
    end

    style Netdata fill:#00b8d4,stroke:#006064,stroke-width:2px,color:white
    style Beszel fill:#f9a825,stroke:#f57f17,stroke-width:2px,color:black
    style BeszelAgent fill:#fdd835,stroke:#fbc02d,stroke-width:2px,color:black
    style User fill:#f57f17,stroke:#e65100,stroke-width:2px,color:white
    style Traefik fill:#7b1fa2,stroke:#4a148c,stroke-width:2px,color:white
```

## 🛠️ Setup

This monitoring stack is managed via Docker Compose.

1.  **Environment Variables:** Create a `.env` file in this directory with the following content:
    ```env
    NETDATA_CLAIM_TOKEN=your_netdata_claim_token
    BEZSEL_TOKEN=your_beszel_token
    BEZSEL_KEY=your_beszel_key
    DOMAIN=jedarabale.space
    ```
2.  **Start the containers:**
    ```bash
    docker-compose up -d
    ```
3.  **Access the dashboards:**
    *   **Netdata:** `https://netdata.jedarabale.space`
    *   **Beszel:** `https://beszel.jedarabale.space`
