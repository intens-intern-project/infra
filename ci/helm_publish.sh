#!/usr/bin/env bash
#
# Packages all charts in a directory and pushes them to a remote registry.
#
# Usage:
#       ./helm_publish.sh ./helmcharts oci://ghcr.io/user/repo
#
# Arguments:
#       $1: root directory of all Helm charts.
#       $2: URI to the backend which stores the charts
#
# All charts must be direct descendants of the specified
# directory argument. Folders which don't have a Chart.yaml
# file will be skipped.
# The residual .tgz packages, saved in the working directory,
# are not deleted.

set -euo pipefail
failed=0

CHARTS_DIR="${1:-helmcharts}"
URI_DEST=$2

echo "Building and pushing all Helm charts in" $CHARTS_DIR

for chart in "$CHARTS_DIR"/*; do
  if [ -f "$chart/Chart.yaml" ]; then
    chart_name=$(echo "$chart" | awk '{ n=split($0, arr, "/"); print arr[n] }')
    chart_version=$(cat $chart/Chart.yaml | grep version | awk '{ print $2 }')
    path=$(printf "./%s-%s.tgz" $chart_name $chart_version)

    helm package "$chart" || failed=1
    helm push $path $URI_DEST || failed=1
  else
    echo "Skipping $chart (not a Helm chart)"
  fi
done

exit $failed