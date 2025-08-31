#!/usr/bin/env bash
set -euo pipefail

REPO="alexandros-thomson/alexandros-thomson"

echo "🌾 Cycle 1 — Harvesting the First Fruits"

# 1. Pull latest canon
git pull origin main

# 2. Inspect relic log
echo "📜 Last 5 relic log entries:"
tail -n 5 workflow-log.md || echo "No workflow-log.md found."

# 3. Inspect metrics CSV
echo "📊 Metrics snapshot:"
if [[ -f logs/workflow-log.csv ]]; then
    column -t -s, logs/workflow-log.csv | tail -n 5
else
    echo "No metrics CSV found."
fi

# 4. Archive the harvest
mkdir -p harvest
cp workflow-log.md logs/workflow-log.csv harvest/ 2>/dev/null || true
git checkout -B harvest-cycle1
git add harvest/
git commit -m "chore: archive harvest-cycle1 relic-run logs" || echo "No changes to commit."
git push -u origin harvest-cycle1

echo "⚖️ Cycle 1.5 — Calibration"

# Quick mode performance check
if [[ -f logs/workflow-log.csv ]]; then
    awk -F, 'NR>1 {count[$3]++; dur[$3]+=$5} END {for (m in count) printf "%s: %d runs, avg duration %.2fs\n", m, count[m], dur[m]/count[m]}' logs/workflow-log.csv
else
    echo "No metrics CSV to analyze."
fi

# Decide mode (simple heuristic: ceremonial if within 5% of plain)
if [[ -f logs/workflow-log.csv ]]; then
    ceremonial_avg=$(awk -F, '/ceremonial/{s+=$5;c++} END{if(c>0) print s/c; else print 9999}' logs/workflow-log.csv)
    plain_avg=$(awk -F, '/plain/{s+=$5;c++} END{if(c>0) print s/c; else print 9999}' logs/workflow-log.csv)
    if (( $(echo "$ceremonial_avg <= $plain_avg * 1.05" | bc -l) )); then
        MODE="ceremonial"
    else
        MODE="plain"
    fi
    echo "🔮 Locking in mode: $MODE"
    gh variable set RELIC_LOG_MODE -b "$MODE" --repo "$REPO"
fi

echo "🚀 Cycle 2 — Expansion"

# Trigger relic minting (placeholder — replace with your actual invocation)
if command -v gh &>/dev/null; then
    echo "Triggering prepare-next-relic sequence..."
    gh workflow run prepare-next-relic.yml --repo "$REPO" --ref main || echo "Manual trigger required."
else
    echo "GitHub CLI not installed — run prepare-next-relic manually."
fi

echo "✅ Ritual complete. Check Actions tab and shrine embeds for results."
