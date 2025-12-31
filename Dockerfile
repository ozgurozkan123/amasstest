FROM node:22-slim

# Install system dependencies and Amass
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates \
       amass \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install pnpm
RUN npm install -g pnpm@8.15.7

# Copy manifest files
COPY package.json ./

# Install dependencies (no lockfile present; will resolve fresh)
RUN pnpm install --frozen-lockfile=false

# Copy source
COPY . .

# Build Next.js app
RUN pnpm run build

ENV HOST=0.0.0.0
ENV PORT=3000
EXPOSE 3000

CMD ["pnpm", "start", "--", "-p", "3000", "-H", "0.0.0.0"]
