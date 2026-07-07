#!/usr/bin/env bash
#
# Runs `helm lint` on all charts in a directory.
# Exits with code 0 on success, 1 on failure.
#
# Usage:
#       ./helm_lint.sh ./helmcharts
#
# Arguments:
#       $1: root directory of all Helm charts.
#
# All charts must be direct descendants of the specified
# directory argument. Folders which don't have a Chart.yaml
# file will be skipped.

set -euo pipefail

CHARTS_DIR="${1:-helmcharts}"
failed=0

echo "Linting all helm charts in" $CHARTS_DIR

for chart in "$CHARTS_DIR"/*; do
  if [ -f "$chart/Chart.yaml" ]; then
    helm lint "$chart" --strict || failed=1
  else
    echo "Skipping $chart (not a Helm chart)"
  fi
done

exit $failed
