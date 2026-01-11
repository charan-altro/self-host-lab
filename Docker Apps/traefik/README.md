# Traefik Reverse Proxy

The cloud-native application proxy. It routes traffic to all the self-hosted services and handles SSL termination.

## 🚀 Solution Architecture

This diagram shows how Traefik acts as the entry point for all incoming traffic, automatically discovering services and securing them with SSL.

```mermaid
graph TD
    subgraph "Internet"
        User(You) -- "HTTPS Requests" --> Traefik
    end

    subgraph "Docker Host"
        Traefik[("Traefik")]
        Traefik -- "Manages Certificates via ACME" --> LetsEncrypt((Let's Encrypt))
        Traefik -- "Auto-discovers Services via Labels" --> DockerSocket((/var/run/docker.sock))
        Traefik -- "Loads Dynamic Configuration" --> ConfigVolume((/etc/traefik/conf))
        
        Traefik -- "Routes to serviceA.domain.com" --> ServiceA[("Service A")]
        Traefik -- "Routes to serviceB.domain.com" --> ServiceB[("Service B")]
        Traefik -- "Routes to ..." --> ServiceC[("...")]
    end

    LetsEncrypt -- "DNS Challenge" --> Cloudflare(Cloudflare API)

    style Traefik fill:#7b1fa2,stroke:#4a148c,stroke-width:2px,color:white
    style User fill:#f57f17,stroke:#e65100,stroke-width:2px,color:white
    style LetsEncrypt fill:#00c853,stroke:#007e33,stroke-width:2px,color:white
    style Cloudflare fill:#f57c00,stroke:#e65100,stroke-width:2px,color:white
```

## 🛠️ Setup

Traefik is managed via Docker Compose and is the core of this self-hosting setup.

1.  **Environment Variables:** Create a `.env` file in this directory with your Cloudflare API token for automatic SSL certificate generation.
    ```env
    CF_DNS_API_TOKEN=your_cloudflare_dns_api_token
    ```
2.  **Configuration:**
    *   `traefik.yaml`: Main configuration file for Traefik.
    *   `conf/`: Directory for dynamic configuration files (e.g., middlewares, TLS options).
    *   `certs/`: Directory for storing generated SSL certificates.
3.  **Start the container:**
    ```bash
    docker-compose up -d
    ```
4.  **Dashboard:** Access the Traefik dashboard at `http://<ip_of_docker_host>:8080` to see the status of your services.
