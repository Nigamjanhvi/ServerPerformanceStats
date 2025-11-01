# ServerPerformance

A tiny DevOps helper to print server performance stats.

- Linux/macOS: `scripts/server_performance.sh`
- Windows (PowerShell): `scripts/server_performance.ps1`

## Features

- CPU usage
- Memory usage (used, free, %)
- Disk usage for root (or all fixed disks on Windows)
- Top 5 processes by CPU and memory
- Uptime, OS version, logged-in users

## Run it

### Linux/macOS (bash)

```bash
chmod +x scripts/server_performance.sh
./scripts/server_performance.sh
```

On macOS without `mpstat`, the script will parse `top`. On Linux, it prefers `mpstat` when present.

### Windows (PowerShell)

```powershell
# If script execution is blocked, run once for this session:
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

./scripts/server_performance.ps1
# Show all fixed disks instead of just C:
./scripts/server_performance.ps1 -AllDisks
```

### Windows with WSL or Git Bash

```bash
./scripts/server_performance.sh
```

## Troubleshooting

- If Git asks for your identity:

```powershell
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

- Keep your history linear when pulling:

```powershell
git config --global pull.rebase true
```

## License

MIT
