# Homepage Dashboard

A modern, fully static, fast, secure fully proxied, browser-based dashboard.

## 🚀 Solution Architecture

This diagram shows how the homepage dashboard serves as a central hub for accessing your self-hosted services.

```mermaid
graph TD
    subgraph "User Interaction"
        User(You) -- "Accesses homepage.jedarabale.space" --> Traefik
    end

    subgraph "Docker Host"
        Traefik[("Traefik Reverse Proxy")] -- "Routes to Homepage" --> Homepage[("Homepage")]
        Homepage -- "Reads Container Status" --> DockerSocket((/var/run/docker.sock))
        Homepage -- "Loads Dashboard Configuration" --> ConfigVolume((Config Volume))
        
        subgraph "Configuration Files"
            direction LR
            ConfigVolume -- "Services" --> Services(services.yaml)
            ConfigVolume -- "Bookmarks" --> Bookmarks(bookmarks.yaml)
            ConfigVolume -- "Widgets" --> Widgets(widgets.yaml)
        end
    end

    style Homepage fill:#3f51b5,stroke:#1a237e,stroke-width:2px,color:white
    style User fill:#f57f17,stroke:#e65100,stroke-width:2px,color:white
    style Traefik fill:#7b1fa2,stroke:#4a148c,stroke-width:2px,color:white
```

## 🛠️ Setup

This service is managed via Docker Compose.

1.  **Customize your dashboard:** Edit the `.yaml` files in the `config` directory to add your own services, bookmarks, and widgets.
    *   `services.yaml`: Define the services to be displayed on the dashboard.
    *   `bookmarks.yaml`: Add your favorite links.
    *   `widgets.yaml`: Configure widgets to display information like CPU usage, memory, etc.
2.  **Start the container:**
    ```bash
    docker-compose up -d
    ```
3.  **Access your dashboard:** Open your browser and navigate to the host defined in your Traefik routing rule (e.g., `https://homepage.jedarabale.space`).
