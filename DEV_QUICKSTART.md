# Codebuff Development Quick Start

## 🚀 Quick Start

```bash
# New contributors - complete setup
make setup

# Everyday development
make dev

# Stop all services
make down
```

## 📋 Essential Commands

| Command          | What it does                   |
| ---------------- | ------------------------------ |
| `make help`      | Show all available commands    |
| `make install`   | Install dependencies           |
| `make dev`       | Start all services (web + CLI) |
| `make web`       | Start web server only          |
| `make cli`       | Start CLI only                 |
| `make test`      | Run all tests                  |
| `make typecheck` | Type check all packages        |
| `make format`    | Format code                    |
| `make build`     | Build all packages             |

## 🛠️ Development Workflow

1. **Start development**: `make dev`
2. **Make changes**: Edit code in your editor
3. **Check quality**: `make watch` (runs format, typecheck, test)
4. **Restart if needed**: `make restart`

## 🌐 Services

- **Web App**: http://localhost:4242
- **Database**: PostgreSQL running in Docker
- **CLI**: Interactive terminal interface
- **DB Studio**: Run `make studio` for database GUI

## 📁 Key Directories

- `agents/` - Agent definitions
- `cli/` - CLI application
- `web/` - Next.js web app
- `common/` - Shared code
- `sdk/` - TypeScript SDK
- `packages/` - Internal packages

## 🔍 Troubleshooting

**Issues with environment variables?**

```bash
# Check your .env.local file
cat .env.local

# Re-run setup
make setup
```

**Database connection issues?**

```bash
# Restart database
make down
make db
```

**Port conflicts?**

- Web app uses port 4242
- Database uses port 5432
- Check with `make status`

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run `make watch` to check quality
5. Submit a PR

Need help? Check [CONTRIBUTING.md](./CONTRIBUTING.md) or join our [Discord](https://codebuff.com/discord)!
