# Vite + React + Nginx + Docker

- **Build Docker image**:

```sh
docker build --no-cache -t dmenezesgabriel/nextjs-app4:v4 ./app4
```

- **Run with dynamic environment variables**:

To pass a dynamic environment variable that will change at runtime set a variable with the prefix `RT_VAR_` in `.env.production` example:

_Important: never set sensitive variables or credentials on `.env.production`, this file will ship to your versioning system (ex: github)._

```sh
VITE_ENVIRONMENT=RT_VAR_ENVIRONMENT
VITE_ALB_DNS_NAME=RT_VAR_DNS_NAME
```

Then pass as environment argument to docker run command:

```sh
docker run \
       --rm \
       --name app4 \
       -p 8080:80 -p 8443:443 \
       -e RT_VAR_ENVIRONMENT=dev \
       -e RT_VAR_DNS_NAME=some_url \
       dmenezesgabriel/nextjs-app4:v4
```
