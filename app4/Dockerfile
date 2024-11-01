FROM node:20-alpine AS build

RUN apk add --no-cache openssl

RUN openssl req -x509 -newkey rsa:4096 -nodes -keyout /etc/ssl/private/key.pem \
    -out /etc/ssl/certs/cert.pem -days 365 \
    -subj "/C=US/ST=State/L=City/O=Organization/OU=Department/CN=localhost"

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the entire application code to the container
COPY . .

# Build the React app for production
RUN npm run build

RUN ls -l /app/dist

# Use Nginx as the production server
FROM nginx:alpine

# Set up HTTPS certificates

# Copy the built React app to Nginx's web server directory
COPY --from=build /app/dist /usr/share/nginx/html
COPY --from=build /etc/ssl /etc/ssl

RUN ls -l /usr/share/nginx/html
RUN ls -l /etc/ssl

# Copy the custom Nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

RUN cat /etc/nginx/nginx.conf

COPY scripts/env.sh /docker-entrypoint.d/env.sh
RUN chmod +x /docker-entrypoint.d/env.sh

# Expose ports 80 and 443 for HTTP and HTTPS
EXPOSE 80 443

# Start Nginx when the container runs
CMD ["nginx", "-g", "daemon off;"]
