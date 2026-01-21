# PDF Compressor

A simple, self-hosted web tool for compressing PDF files. By hosting your own PDF compressor, you can reduce the size of your documents without uploading them to a third-party service, ensuring the privacy and security of your data. It's a fast and effective way to optimize your PDFs for sharing and storage.

## 🚀 Solution Architecture

This diagram shows how the PDF Compressor service is accessed through Traefik to compress your PDF files.

```mermaid
graph TD
    subgraph "User Interaction"
        User(You) -- "Accesses pdf.jedarabale.space" --> Traefik
        User -- "1. Uploads PDF" --> PDFCompressor
        PDFCompressor -- "2. Compresses PDF" --> PDFCompressor
        PDFCompressor -- "3. Returns Compressed PDF" --> User
    end

    subgraph "Docker Host"
        Traefik[("Traefik Reverse Proxy")] -- "Routes to PDF Compressor" --> PDFCompressor[("PDF Compressor")]
    end

    style PDFCompressor fill:#d32f2f,stroke:#b71c1c,stroke-width:2px,color:white
    style User fill:#f57f17,stroke:#e65100,stroke-width:2px,color:white
    style Traefik fill:#7b1fa2,stroke:#4a148c,stroke-width:2px,color:white
```

## 🛠️ Setup

This service is managed via Docker Compose.

1.  **Start the container:**
    ```bash
    docker-compose up -d
    ```
2.  **Access the service:** Open your browser and navigate to `https://pdf.jedarabale.space` to start compressing your PDF files.
