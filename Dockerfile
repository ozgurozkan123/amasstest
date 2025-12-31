FROM node:22-slim

# Install dependencies and fetch Amass binary
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates wget curl unzip \
    && rm -rf /var/lib/apt/lists/*

RUN set -e; \
    AMASS_URL=$(curl -s https://api.github.com/repos/OWASP/Amass/releases/latest | grep "browser_download_url.*linux_amd64.zip" | head -n1 | cut -d '"' -f4); \
    echo "Downloading $AMASS_URL"; \
    wget -O /tmp/amass.zip "$AMASS_URL"; \
    unzip /tmp/amass.zip -d /tmp; \
    mv /tmp/amass_linux_amd64/amass /usr/local/bin/amass; \
    chmod +x /usr/local/bin/amass; \
    rm -rf /tmp/amass*;

WORKDIR /app

# Install pnpm
RUN npm install -g pnpm@8.15.7

# Copy manifest files
COPY package.json ./

# Install dependencies
RUN pnpm install --frozen-lockfile=false

# Copy source
COPY . .

# Build Next.js app
RUN pnpm run build

ENV HOST=0.0.0.0
ENV PORT=3000
EXPOSE 3000

CMD ["pnpm", "start", "--", "-p", "3000", "-H", "0.0.0.0"]
