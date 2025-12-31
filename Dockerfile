FROM node:22-slim

# Install dependencies and Go (for building Amass)
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates wget unzip golang \
    && rm -rf /var/lib/apt/lists/*

# Install Amass via Go modules
RUN GOBIN=/usr/local/bin GO111MODULE=on go install github.com/owasp-amass/amass/v4/...@latest

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
