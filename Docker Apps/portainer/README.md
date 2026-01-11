# Portainer

A powerful, lightweight management UI that allows you to easily manage your Docker environments. With Portainer, you can inspect and manage containers, images, volumes, and networks, deploy applications from stacks, and monitor your Docker host, all from an intuitive web interface. It simplifies the complexities of the command line and provides a clear overview of your containerized applications.

## 🚀 Solution Architecture

This diagram shows how Portainer provides a web interface to manage your Docker environment.

```mermaid
graph TD
    subgraph "User Interaction"
        User(You) -- "Accesses portainer.jedarabale.space" --> Traefik
    end

    subgraph "Docker Host"
        Traefik[("Traefik Reverse Proxy")] -- "Routes to Portainer" --> Portainer[("Portainer")]
        Portainer -- "Manages Docker Environment" --> DockerSocket((/var/run/docker.sock))
        Portainer -- "Stores Data" --> PortainerDataVolume((portainer_data))
    end

    style Portainer fill:#1E88E5,stroke:#0D47A1,stroke-width:2px,color:white
    style User fill:#f57f17,stroke:#e65100,stroke-width:2px,color:white
    style Traefik fill:#7b1fa2,stroke:#4a148c,stroke-width:2px,color:white
```

## 🛠️ Setup

This Portainer instance is managed via Docker Compose.

1.  **Start the container:**
    ```bash
    docker-compose up -d
    ```
2.  **Access Portainer:** Open your browser and navigate to `https://portainer.jedarabale.space`.
3.  **Initial Setup:** On your first visit, you will be asked to create an admin user and connect to a Docker environment. Choose the "Docker" option and connect to the local Docker socket.
