  #!/usr/bin/env bash
    set -euo pipefail
    
    # Extract Postgres host:port from DATABASE_URL
    if [[ "$DATABASE_URL" =~ @([^:/]+)(:([0-9]+))? ]]; then
      HOST="${BASH_REMATCH[1]}"
      PORT="${BASH_REMATCH[3]:-5432}"
    
      echo "ℹ️ Waiting for Postgres at ${HOST}:${PORT}..."
      # Use wget to test TCP port instead of netcat (broader compatibility)
      timeout 60 bash -c "until wget --quiet --spider --timeout=1 tcp://${HOST}:${PORT} 2>/dev/null; do sleep 1; done"
      echo "✅ Postgres is online"
    
      # Run migrations using the internal package script
      echo "🛠 Running database migrations..."
      bun --cwd packages/internal run db:migrate || echo "⚠️ Migrations skipped or failed"
    fi
    
    # Forward Docker CMD to Bun
    exec "$@"
    # End of entrypoint script
    