#!/usr/bin/env bash
# shellcheck disable=SC2015
set -euo pipefail

# -----------------------------------------------------------------------------
# Codebuff — local development bootstrap
# -----------------------------------------------------------------------------
# Aligns with CONTRIBUTING.md: Bun + Docker (Postgres) for most contributors.
# Optional second mode builds/runs the full Docker "app" image with custom Nvidia.
#
# Usage:
#   ./setup.sh                 # default: DB + deps + migrations (recommended)
#   ./setup.sh --docker-app    # full Docker image + app container (+ Nvidia key)
#   ./setup.sh --help
#
# Docs: ./CONTRIBUTING.md · ./docs/development.md
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

# -------------------- shared config (matches root docker-compose.yml) --------------------
DB_USER="manicode_user_local"
DB_PASS="secretpassword_local"
DB_NAME="manicode_db_local"
DB_HOST="localhost"
DB_PORT="5432"

ENV_FILE="packages/internal/.env"
NVIDIA_SECRET_FILE="${SCRIPT_DIR}/codebuff_nvidia_key.txt"
APP_IMAGE="codebuff-app:custom"

# Bun: package.json "engines" recommends this; setup.sh only hard-fails below the floor.
RECOMMENDED_BUN_VERSION="1.3.11"
FLOOR_BUN_VERSION="1.3.0"

die() {
  echo "error: $*" >&2
  exit 1
}

have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

# Returns 0 if $1 >= $2 (semver-ish).
semver_ge() {
  [[ "$(printf '%s\n' "$2" "$1" | sort -V | tail -n1)" == "$1" ]]
}

bun_version_string() {
  local raw v
  raw="$(bun --version 2>/dev/null || true)"
  [[ -z "$raw" ]] && return 1
  v="${raw#bun v}"
  v="${v#bun }"
  v="${v%%-*}"
  printf '%s' "${v}"
}

ensure_internal_env_database_url() {
  local url="postgresql://${DB_USER}:${DB_PASS}@${DB_HOST}:${DB_PORT}/${DB_NAME}"
  mkdir -p "$(dirname "${ENV_FILE}")"

  if [[ ! -f "${ENV_FILE}" ]]; then
    echo "Creating ${ENV_FILE} with DATABASE_URL and PORT."
    cat >"${ENV_FILE}" <<EOF
DATABASE_URL=${url}
PORT=4242
EOF
    return
  fi

  if grep -q "^DATABASE_URL=" "${ENV_FILE}"; then
    if [[ "$(uname -s)" == "Darwin" ]]; then
      sed -i '' "s|^DATABASE_URL=.*|DATABASE_URL=${url}|" "${ENV_FILE}"
    else
      sed -i "s|^DATABASE_URL=.*|DATABASE_URL=${url}|" "${ENV_FILE}"
    fi
  else
    echo "DATABASE_URL=${url}" >>"${ENV_FILE}"
  fi

  grep -q "^PORT=" "${ENV_FILE}" || echo "PORT=4242" >>"${ENV_FILE}"
}

preflight_docker() {
  if ! docker info >/dev/null 2>&1; then
    die "Docker is not running. Start Docker Desktop (or dockerd) and retry."
  fi
  if ! docker compose version >/dev/null 2>&1; then
    die "'docker compose' not found. Install Docker Compose v2."
  fi
}

preflight_bun() {
  local v raw_display
  have_cmd bun || die "Bun is not installed. See https://bun.sh/docs/installation"
  raw_display="$(bun --version 2>/dev/null || echo unknown)"
  v="$(bun_version_string)" || die "Could not parse Bun version (got: ${raw_display})"

  if ! semver_ge "${v}" "${FLOOR_BUN_VERSION}"; then
    die "Bun >= ${FLOOR_BUN_VERSION} required for this repo (found: ${raw_display}). Upgrade: https://bun.sh/docs/installation"
  fi

  if ! semver_ge "${v}" "${RECOMMENDED_BUN_VERSION}"; then
    echo "warning: package.json recommends Bun ${RECOMMENDED_BUN_VERSION}; you have ${v} (${raw_display})." >&2
    echo "warning: Upgrade when possible:  bun upgrade   (or reinstall from https://bun.sh )" >&2
  fi
}

run_minimal_setup() {
  echo "==> Codebuff contributor setup (database + dependencies)"
  preflight_bun
  preflight_docker

  echo "==> bun install (workspace)"
  bun install

  echo "==> ${ENV_FILE}"
  ensure_internal_env_database_url
  echo "    DATABASE_URL points at local Docker Postgres (${DB_HOST}:${DB_PORT})."

  echo "==> Starting Postgres (docker compose: service db)"
  docker compose up -d --wait db

  echo "==> Drizzle migrations (packages/internal)"
  # Use a subshell: `bun --cwd … run db:migrate` can omit the script on some Bun versions (prints `bun run` help, exits 0).
  if (cd packages/internal && bun run db:migrate); then
    echo "    Migrations applied."
  else
    echo "    warning: db:migrate failed or skipped — check packages/internal package.json and DB logs."
  fi

  echo ""
  echo "Next steps (see CONTRIBUTING.md):"
  echo "  1. Copy env for the web app if you have not yet:"
  echo "       cp .env.example .env.local"
  echo "     Then set OPEN_ROUTER_API_KEY, GitHub OAuth, NEXTAUTH_*, etc."
  echo "  2. Terminal 1:  bun run start-web    → http://localhost:3000"
  echo "  3. Terminal 2:  bun run start-cli"
  echo "  4. Before PR:    bun run typecheck && make test   (or: bun test)"
  echo ""
  echo "Stop DB:  docker compose down"
  echo "Full Docker UI + custom Nvidia model:  ./setup.sh --docker-app"
}

run_docker_app_setup() {
  echo "==> Full Docker app image + container (custom Nvidia / integrate.api.nvidia.com)"
  preflight_bun
  preflight_docker

  if [[ -n "${CODEBUFF_CUSTOM_MODEL_API_KEY:-}" ]]; then
    :
  elif [[ -f "${NVIDIA_SECRET_FILE}" ]]; then
    CODEBUFF_CUSTOM_MODEL_API_KEY="$(tr -d '[:space:]' <"${NVIDIA_SECRET_FILE}")"
    export CODEBUFF_CUSTOM_MODEL_API_KEY
  else
    die "Set CODEBUFF_CUSTOM_MODEL_API_KEY or create ${NVIDIA_SECRET_FILE} (one line, raw API key)."
  fi

  ensure_internal_env_database_url

  echo "==> Building image ${APP_IMAGE} (may take a few minutes)…"
  DOCKER_BUILDKIT=1 docker build --no-cache -t "${APP_IMAGE}" .

  echo "==> Starting Postgres"
  docker compose up -d --wait db

  echo "==> Migrations"
  (cd packages/internal && bun run db:migrate) || echo "warning: migrations step reported an error (see above)."

  echo "==> Starting app container"
  docker compose -f docker-compose.yml up -d app

  echo ""
  docker compose -f docker-compose.yml ps
  echo ""
  echo "UI:   http://localhost:3000"
  echo "Stop: docker compose -f docker-compose.yml down -v"
}

print_help() {
  cat <<'EOF'
Usage:
  ./setup.sh                 Default: Postgres + bun install + migrations (see CONTRIBUTING.md).
  ./setup.sh --minimal       Same as default.
  ./setup.sh --docker-app    Build/run full Docker app image (needs Nvidia custom-model key).
  ./setup.sh --help

Environment (optional):
  CODEBUFF_CUSTOM_MODEL_API_KEY   For --docker-app if you prefer not to use codebuff_nvidia_key.txt

Documentation:
  CONTRIBUTING.md · docs/development.md
EOF
}

case "${1:-}" in
  -h | --help | help)
    print_help
    exit 0
    ;;
  --docker-app)
    run_docker_app_setup
    ;;
  "" | --minimal)
    run_minimal_setup
    ;;
  *)
    die "Unknown option: $1. Use --help."
    ;;
esac
