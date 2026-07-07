#!/usr/bin/env bash
#
# Extracts versions for all helm charts in a format suitable for
# Terraform deployment. The format is following:
#
# '{"var_1":"1.2.3","var_2":"1.0.0","var_3":"0.1.0",}'
# 
# Note the trailing comma.
#
# Usage:
#       ./get_chart_versions.sh ./helmcharts
#
# Arguments:
#       $1: root directory of all Helm charts.
#
# All charts must be direct descendants of the specified
# directory argument. Folders which don't have a Chart.yaml
# file will be skipped.
#
# Outputs the result to stdout.

set -euo pipefail

CHARTS_DIR="${1:-helmcharts}"

values="'{"

for chart in "$CHARTS_DIR"/*; do
  if [ -f "$chart/Chart.yaml" ]; then
    chart_name=$(echo "$chart" | awk '{ n=split($0, arr, "/"); print arr[n] }')
    chart_version=$(cat $chart/Chart.yaml | grep version | awk '{ print $2 }')

    values+=$(printf "\"%s\":\"%s\"," $chart_name $chart_version)
  fi
done

values+="}'"

echo $values