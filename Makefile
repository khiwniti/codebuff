BUN ?= $(shell command -v bun 2>/dev/null || echo ./.bin/bun)

.DEFAULT_GOAL := help

.PHONY: help install deps up down ps cli start web db studio format test typecheck clean init-worktree cleanup-worktree tools

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Setup"
	@echo "  install        Install workspace dependencies with bun"
	@echo "  deps           Alias for install"
	@echo ""
	@echo "Services"
	@echo "  up             Start db, studio, sdk build, web (background)"
	@echo "  down           Stop background services"
	@echo "  ps             Show background service status"
	@echo "  start          Start services then launch the CLI"
	@echo "  cli            Run the CLI in the foreground"
	@echo "  web            Start web with db (foreground)"
	@echo "  db             Start database only"
	@echo "  studio         Start Drizzle Studio"
	@echo ""
	@echo "Quality"
	@echo "  format         Run prettier across the repo"
	@echo "  test           Run workspace tests"
	@echo "  typecheck      Run type checks"
	@echo "  clean          Remove build artifacts and reinstall deps"
	@echo ""
	@echo "Maintenance"
	@echo "  init-worktree  Initialize workspace files"
	@echo "  cleanup-worktree Clean up workspace files"
	@echo "  tools          Regenerate tool definitions"
	@echo ""
	@echo "Set BUN=/path/to/bun to override the bun binary."

install deps:
	$(BUN) install

up:
	$(BUN) up

down:
	$(BUN) down

ps:
	$(BUN) ps

start: up
	$(BUN) start-cli

cli:
	$(BUN) start-cli

web:
	$(BUN) start-web

db:
	$(BUN) start-db

studio:
	$(BUN) start-studio

format:
	$(BUN) format

test:
	$(BUN) test

typecheck:
	$(BUN) typecheck

clean:
	$(BUN) clean-ts

init-worktree:
	$(BUN) init-worktree

cleanup-worktree:
	$(BUN) cleanup-worktree

tools:
	$(BUN) generate-tool-definitions
