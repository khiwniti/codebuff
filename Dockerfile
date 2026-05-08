# ---------- Build stage ----------
ARG TARGETARCH=amd64
FROM --platform=linux/${TARGETARCH} node:20-slim AS builder
WORKDIR /app

# Install system deps (curl, git, openssh, ca-certificates, unzip)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git openssh-client ca-certificates unzip && \
    rm -rf /var/lib/apt/lists/*

# Install Bun (fast JS/TS runtime & package manager)
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:${PATH}"

# Copy the full repository and install dependencies
COPY . .
# Clean any previous Bun cache to avoid corrupted tarballs
RUN rm -rf /root/.bun/install/cache
# Force re‑download in case a cached tarball is corrupted
ENV BUN_INSTALL_FORCE=1
ENV BUN_ARCH=amd64
ENV BUN_PLATFORM=linux/amd64
RUN bun install --no-optional || true

# ---------- Runtime stage ----------
ARG TARGETARCH
FROM --platform=linux/${TARGETARCH} node:20-slim AS runtime
WORKDIR /app
ENV PATH="/root/.bun/bin:${PATH}"

# Install runtime utilities (curl, bash, netcat)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl bash netcat-openbsd && rm -rf /var/lib/apt/lists/*

# Copy Bun binary from builder
COPY --from=builder /root/.bun /root/.bun
# Copy application code
COPY --from=builder /app /app

# Default env vars (override at runtime if needed)
ENV PORT=3000
ENV DATABASE_URL=postgresql://manicode_user_local:secretpassword_local@db:5432/manicode_db_local
ENV CODEBUFF_CUSTOM_MODEL_BASE_URL=""
ENV CODEBUFF_CUSTOM_MODEL_API_KEY=""

# Expose ports: web UI (3000) and optional CLI dev server (4242)
EXPOSE 3000 4242

# Entrypoint script (waits for DB, runs migrations)
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
# Default command – launch the web UI; override for CLI usage
CMD ["bun", "run", "start-web"]
