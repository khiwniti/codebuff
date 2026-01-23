# Multi-stage Dockerfile for CodeBuff Next.js Application
# Optimized for Railway deployment with proper dependency handling

# Stage 1: Dependencies
FROM node:20-alpine AS deps
WORKDIR /app

# Install openssl for Prisma
RUN apk add --no-cache libc6-compat openssl

# Copy package files for workspace
COPY package.json bun.lock* package-lock.json* yarn.lock* pnpm-lock.yaml* ./
COPY web/package.json ./web/
COPY packages/internal/package.json ./packages/internal/
COPY packages/agent-runtime/package.json ./packages/agent-runtime/
COPY packages/build-tools/package.json ./packages/build-tools/
COPY common/package.json ./common/
COPY sdk/package.json ./sdk/

# Install dependencies using npm (more reliable in Docker than bun)
RUN npm ci --legacy-peer-deps || npm install --legacy-peer-deps

# Stage 2: Builder
FROM node:20-alpine AS builder
WORKDIR /app

# Install openssl for Prisma
RUN apk add --no-cache libc6-compat openssl

# Copy dependencies from deps stage
COPY --from=deps /app/node_modules ./node_modules
COPY --from=deps /app/web/node_modules ./web/node_modules

# Copy all source files
COPY . .

# Set environment for build
ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_ENV=production

# Build the Next.js application
WORKDIR /app/web
RUN npm run build

# Stage 3: Runner
FROM node:20-alpine AS runner
WORKDIR /app

# Install openssl for Prisma runtime
RUN apk add --no-cache libc6-compat openssl

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# Create non-root user
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy necessary files from builder
COPY --from=builder /app/web/next.config.mjs ./web/
COPY --from=builder /app/web/package.json ./web/

# Copy built Next.js files
COPY --from=builder --chown=nextjs:nodejs /app/web/.next ./web/.next
COPY --from=builder --chown=nextjs:nodejs /app/web/public ./web/public

# Copy node_modules (includes all workspace dependencies)
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/web/node_modules ./web/node_modules

# Copy workspace packages that are runtime dependencies
COPY --from=builder /app/packages ./packages
COPY --from=builder /app/common ./common
COPY --from=builder /app/sdk ./sdk

# Copy Prisma schema and migrations for runtime
COPY --from=builder /app/packages/internal/prisma ./packages/internal/prisma

# Copy root package.json for workspace resolution
COPY --from=builder /app/package.json ./

USER nextjs

EXPOSE 3000

ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

WORKDIR /app/web

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/api/healthz', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Start the application
CMD ["node_modules/.bin/next", "start"]
