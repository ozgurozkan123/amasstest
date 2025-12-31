FROM node:22-slim

# Install dependencies and Amass binary
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates wget \
    && rm -rf /var/lib/apt/lists/*

ENV AMASS_VERSION=5.0.1
RUN wget -q https://github.com/owasp-amass/amass/releases/download/v${AMASS_VERSION}/amass_Linux_amd64.tar.gz -O /tmp/amass.tar.gz \
    && tar -xzf /tmp/amass.tar.gz -C /tmp \
    && mv /tmp/amass_Linux_amd64/amass /usr/local/bin/amass \
    && chmod +x /usr/local/bin/amass \
    && rm -rf /tmp/amass.tar.gz /tmp/amass_Linux_amd64

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
