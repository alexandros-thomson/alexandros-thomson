#!/usr/bin/env bash
set -euo pipefail

# Usage: PUSHGATEWAY_URL="http://pushgateway:9091" ./pushgateway_helper.sh <amount>
PUSHGATEWAY_URL=${PUSHGATEWAY_URL:-}
AMOUNT=${1:-100}
JOB=${JOB:-crown_convergence}

if [ -z "$PUSHGATEWAY_URL" ]; then
  echo "ERROR: Set PUSHGATEWAY_URL environment variable to pushgateway endpoint (e.g. http://pushgateway:9091)"
  exit 2
fi

cat <<EOF | curl --silent --data-binary @- "${PUSHGATEWAY_URL}/metrics/job/${JOB}"
# TYPE crown_revenue_total counter
crown_revenue_total ${AMOUNT}
EOF

echo "Pushed crown_revenue_total=${AMOUNT} to ${PUSHGATEWAY_URL}/metrics/job/${JOB}"
