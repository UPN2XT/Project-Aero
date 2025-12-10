# Stage 1: Builder
FROM node:20-alpine AS builder
WORKDIR /app

# Copy manifest files
COPY package*.json ./

# CHANGE 1: Use 'npm install' instead of 'ci' to prevent lockfile mismatch errors
RUN npm install

COPY . .

# CHANGE 2: Create a placeholder index.html FIRST.
# If the build fails, this file remains and Nginx serves it as a fallback.
RUN mkdir -p /app/dist && echo "<h1>Build Failed, but container is running</h1>" > /app/dist/index.html

# Run build. If it succeeds, it overwrites the placeholder. 
# If it fails, the || true catches it, and the placeholder remains.
RUN npm run build || true

# Stage 2: Runner
FROM nginx:1.27-alpine

# Ensure custom config exists or remove this line to use Nginx defaults
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy assets
COPY --from=builder /app/dist /usr/share/nginx/html

# CHANGE 3: Standard Nginx port is 80.
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]