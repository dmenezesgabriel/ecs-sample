# Vite + React + Nginx + Docker

- **Build Docker image**:

```sh
docker build --no-cache -t dmenezesgabriel/nextjs-app4:v4 ./app4
```

- **Run with dynamic environment variables**:

```sh
docker run \
       --rm \
       --name app4 \
       -p 8080:80 -p 8443:443 \
       -e RT_VAR_ENVIRONMENT=dev \
       -e RT_VAR_DNS_NAME=some_url \
       dmenezesgabriel/nextjs-app4:v4
```
