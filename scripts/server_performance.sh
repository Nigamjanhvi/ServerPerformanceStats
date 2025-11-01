#!/usr/bin/env bash
set -euo pipefail

banner() {
  echo "=============================="
  echo "   SERVER PERFORMANCE STATS"
  echo "=============================="
}

section() {
  echo
  echo "🔹 $1"
}

human() { # bytes to human readable
  local bytes=${1:-0}
  local kib=1024 mib=$((1024*1024)) gib=$((1024*1024*1024))
  if (( bytes >= gib )); then printf "%.2f GiB" "$(awk -v b=$bytes 'BEGIN{print b/1073741824}')";
  elif (( bytes >= mib )); then printf "%.2f MiB" "$(awk -v b=$bytes 'BEGIN{print b/1048576}')";
  elif (( bytes >= kib )); then printf "%.2f KiB" "$(awk -v b=$bytes 'BEGIN{print b/1024}')";
  else printf "%d B" "$bytes"; fi
}

cpu_usage_linux() {
  # Prefer mpstat if available (more stable across locales)
  if command -v mpstat >/dev/null 2>&1; then
    local idle
    idle=$(mpstat 1 1 | awk '/Average/ && $NF ~ /id/ {print $(NF-1)}') || idle=0
    awk -v i="${idle:-0}" 'BEGIN{printf "CPU Usage: %.2f%%\n", 100-i}'
  else
    # Fallback to parsing top
    local idle
    idle=$(LANG=C top -bn1 | awk -F',' '/Cpu\(s\)/{for(i=1;i<=NF;i++){if($i~/%id/){gsub(/[^0-9.]/,"",$i); print $i; exit}}}') || idle=0
    awk -v i="${idle:-0}" 'BEGIN{printf "CPU Usage: %.2f%%\n", 100-i}'
  fi
}

cpu_usage_macos() {
  # macOS: top -l 1 line with CPU usage
  local idle
  idle=$(top -l 1 | awk -F',' '/CPU usage/{for(i=1;i<=NF;i++){if($i~/% idle/){gsub(/[^0-9.]/,"",$i); print $i; exit}}}') || idle=0
  awk -v i="${idle:-0}" 'BEGIN{printf "CPU Usage: %.2f%%\n", 100-i}'
}

memory_linux() {
  # Use /proc/meminfo for consistent numeric values (kB)
  local mem_total mem_free mem_buffers mem_cached mem_available used used_pct
  mem_total=$(awk '/MemTotal:/ {print $2*1024}' /proc/meminfo)
  mem_available=$(awk '/MemAvailable:/ {print $2*1024}' /proc/meminfo)
  used=$((mem_total - mem_available))
  used_pct=$(awk -v u=$used -v t=$mem_total 'BEGIN{printf "%.2f", (u*100)/t}')
  printf "Used: %s | Free: %s | Usage: %s%%\n" "$(human "$used")" "$(human "$mem_available")" "$used_pct"
}

memory_macos() {
  # macOS vm_stat gives pages; page size from sysctl
  local page_size free_pages active_pages inactive_pages speculative_pages wired_pages total_used used_pct
  page_size=$(sysctl -n hw.pagesize)
  free_pages=$(vm_stat | awk '/Pages free/ {gsub(".","",$3); print $3}')
  inactive_pages=$(vm_stat | awk '/Pages inactive/ {gsub(".","",$3); print $3}')
  speculative_pages=$(vm_stat | awk '/Pages speculative/ {gsub(".","",$3); print $3}')
  wired_pages=$(vm_stat | awk '/Pages wired down/ {gsub(".","",$4); print $4}')
  active_pages=$(vm_stat | awk '/Pages active/ {gsub(".","",$3); print $3}')
  total_used=$(( (active_pages + wired_pages + inactive_pages + speculative_pages) * page_size ))
  total_mem=$(sysctl -n hw.memsize)
  used_pct=$(awk -v u=$total_used -v t=$total_mem 'BEGIN{printf "%.2f", (u*100)/t}')
  printf "Used: %s | Free: %s | Usage: %s%%\n" "$(human "$total_used")" "$(human $((total_mem-total_used)))" "$used_pct"
}

disk_usage_root() {
  df -h / | awk 'NR==2{printf "Used: %s | Free: %s | Usage: %s\n", $3, $4, $5}'
}

header() {
  banner
}

main() {
  header
  section "CPU Usage:"
  case "${OSTYPE:-}" in
    linux*) cpu_usage_linux ;;
    darwin*) cpu_usage_macos ;;
    *) echo "Unknown OS for CPU metrics" ;;
  esac

  section "Memory Usage:"
  case "${OSTYPE:-}" in
    linux*) memory_linux ;;
    darwin*) memory_macos ;;
    *) echo "Unknown OS for memory metrics" ;;
  esac

  section "Disk Usage:"
  disk_usage_root

  section "Top 5 CPU-consuming processes:"
  ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6 || true

  section "Top 5 Memory-consuming processes:"
  ps -eo pid,comm,%mem --sort=-%mem | head -n 6 || true

  section "Uptime:"
  if command -v uptime >/dev/null 2>&1; then uptime -p || uptime; fi

  section "OS Version:"
  if [ -f /etc/os-release ]; then
    grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"'
  else
    uname -a
  fi

  section "Logged-in users:"
  if command -v who >/dev/null 2>&1; then who | wc -l; fi

  echo
  echo "=============================="
  echo "       END OF REPORT"
  echo "=============================="
}

main "$@"
