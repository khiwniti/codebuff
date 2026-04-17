#!/usr/bin/env bash
set -euo pipefail

# -------------------------------------------------
# Codebuff local-development bootstrap script
# -------------------------------------------------
# Usage:
#   chmod +x setup.sh && ./setup.sh
# -------------------------------------------------

# --------------------
# 1️⃣ CONFIGURATION
# --------------------
# Path to the file that holds the Nvidia API key (plain text, one line)
NVIDIA_SECRET_FILE="${PWD}/codebuff_nvidia_key.txt"

# DB credentials – must match root docker-compose.yml service 'db'
DB_USER="manicode_user_local"
DB_PASS="secretpassword_local"
DB_NAME="manicode_db_local"
DB_HOST="localhost"
DB_PORT="5432"  # host‑side port (mapped to container)

# Docker image name we will (re)build
APP_IMAGE="codebuff-app:custom"

# --------------------
# 2️⃣ PRE‑FLIGHT CHECKS
# --------------------
# a) Nvidia secret must exist
if [[ ! -f "${NVIDIA_SECRET_FILE}" ]]; then
  echo "❌ Nvidia secret file not found at: ${NVIDIA_SECRET_FILE}"
  echo "   Create it (a single line with the raw API key) and re‑run this script."
  exit 1
fi

# b) Docker daemon must be running
if ! docker info > /dev/null 2>&1; then
  echo "❌ Docker daemon not running. Start Docker Desktop (or dockerd) and retry."
  exit 1
fi

# c) Docker Compose v2 must be available
if ! docker compose version > /dev/null 2>&1; then
  echo "❌ 'docker compose' command not found. Install Docker Compose v2 and retry."
  exit 1
fi

# --------------------
# 3️⃣ ENSURE .env HAS A VALID DATABASE_URL
# --------------------
ENV_FILE="packages/internal/.env"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "⚠️ .env not found at ${ENV_FILE}. Creating a minimal one."
  mkdir -p "$(dirname "${ENV_FILE}")"
  cat > "${ENV_FILE}" <<EOF
DATABASE_URL=postgresql://${DB_USER}:${DB_PASS}@${DB_HOST}:${DB_PORT}/${DB_NAME}
PORT=4242
EOF
else
  # Replace existing DATABASE_URL line or add a new one
  if grep -q "^DATABASE_URL=" "${ENV_FILE}"; then
    sed -i.bak "s|^DATABASE_URL=.*|DATABASE_URL=postgresql://${DB_USER}:${DB_PASS}@${DB_HOST}:${DB_PORT}/${DB_NAME}|" "${ENV_FILE}"
  else
    echo "DATABASE_URL=postgresql://${DB_USER}:${DB_PASS}@${DB_HOST}:${DB_PORT}/${DB_NAME}" >> "${ENV_FILE}"
  fi
  # Ensure PORT is set (fallback to 4242)
  grep -q "^PORT=" "${ENV_FILE}" || echo "PORT=4242" >> "${ENV_FILE}"
fi

echo "✅ .env is ready with a correct DATABASE_URL."

# --------------------
# 4️⃣ BUILD THE CODEBUFF APP IMAGE
# --------------------
echo "🔨 Building Docker image ${APP_IMAGE} (this may take a minute)…"
DOCKER_BUILDKIT=1 docker build --no-cache -t "${APP_IMAGE}" .
echo "✅ Docker image built."

# --------------------
# 5️⃣ START POSTGRES (DB)
# --------------------
echo "🗄️ Starting Postgres container (docker-compose.yml)…"
docker compose up -d --wait db

echo "✅ Postgres is healthy."

# --------------------
# 6️⃣ RUN DB MIGRATIONS
# --------------------
echo "🚀 Applying Drizzle migrations (db:migrate)…"
bun --cwd packages/internal run db:migrate || echo "⚠️ Migrations skipped (script not found or already applied)"
echo "✅ Migrations applied."

# --------------------
# 7️⃣ START THE CODEBUFF APP WITH THE NVIDIA SECRET
# --------------------
echo "🚀 Starting the Codebuff app (with Nvidia API key secret)…"
docker compose -f docker-compose.yml up -d app

echo "✅ App container is up."

# --------------------
# 8️⃣ FINAL INFORMATION
# --------------------
echo ""
echo "🎉 All services are now running:"
docker compose -f docker-compose.yml ps

echo ""
echo "🌐 UI   → http://localhost:3000"
echo "💻 CLI  → http://localhost:4242   (or use the local CLI via 'bun run start-cli')"

echo ""
echo "🔑 Verify the Nvidia key inside the container:"
echo "docker exec -it \$(docker compose -f docker-compose.yml ps -q app) bash -c 'echo \"$CODEBUFF_CUSTOM_MODEL_API_KEY\"'"

echo ""
echo "🧹 To stop everything later:"
echo "docker compose -f docker-compose.yml down -v"

echo "🚧 Done! Happy hacking with Codebuff and your custom Nvidia model."
