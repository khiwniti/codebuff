#!/bin/bash

# Codebuff Development Setup Script
echo "🚀 Starting Codebuff Development Environment..."

# Set up environment
export PATH="$HOME/.bun/bin:$PATH"

# Start web server in background
echo "📡 Starting web server..."
bun --env-file=.env.local run start-web &
WEB_PID=$!

# Wait for web server to be ready
echo "⏳ Waiting for web server to start..."
sleep 10

# Start CLI
echo "💻 Starting CLI..."
echo "Web server is running on http://localhost:4242"
echo "CLI is starting below..."
echo ""

bun --env-file=.env.local run start-cli

# Cleanup on exit
trap "kill $WEB_PID 2>/dev/null" EXIT