#!/usr/bin/env bash
# Clean up unnecessary Railway services
# Only @codebuff/web should be deployed - all others are internal libraries

set -e

echo "========================================"
echo "Railway Services Cleanup Script"
echo "========================================"
echo ""
echo "This script will delete unnecessary Railway services."
echo "Only @codebuff/web needs to be deployed - all other packages"
echo "are TypeScript libraries that are bundled into the web app."
echo ""

# Check if Railway CLI is available
if ! command -v railway &> /dev/null; then
    echo "❌ Railway CLI not found. Please install it first:"
    echo "   npm install -g @railway/cli"
    exit 1
fi

# Check current status
echo "Current services status:"
echo ""
railway service status --all
echo ""

# Services to delete (everything except web)
SERVICES_TO_DELETE=(
    "@codebuff/build-tools"
    "@codebuff/agent-runtime"
    "@codebuff/code-map"
    "@codebuff/.agents"
    "@codebuff/cli"
    "@codebuff/billing"
    "@codebuff/evals"
    "@codebuff/bigquery"
    "@codebuff/sdk"
    "@codebuff/agents"
    "@codebuff/internal"
)

echo "⚠️  WARNING: This will delete ${#SERVICES_TO_DELETE[@]} services:"
echo ""
for service in "${SERVICES_TO_DELETE[@]}"; do
    echo "  - $service"
done
echo ""
echo "These are internal library packages that should NOT be deployed."
echo "They are already bundled into @codebuff/web during build."
echo ""

read -p "Do you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "❌ Cancelled. No services were deleted."
    exit 0
fi

echo ""
echo "Deleting services..."
echo ""

# Delete each service
for service in "${SERVICES_TO_DELETE[@]}"; do
    echo "Deleting $service..."
    if railway service delete "$service" --yes 2>&1; then
        echo "✅ Deleted $service"
    else
        echo "⚠️  Failed to delete $service (might already be gone or need manual deletion)"
    fi
    echo ""
done

echo ""
echo "========================================"
echo "Cleanup Complete!"
echo "========================================"
echo ""
echo "Remaining services:"
railway service status --all
echo ""
echo "You should now have only:"
echo "  - @codebuff/web (ACTIVE or DEPLOYING)"
echo "  - postgres (if database was added)"
echo ""
echo "All internal packages are bundled into the web deployment."
echo "No functionality is lost!"
