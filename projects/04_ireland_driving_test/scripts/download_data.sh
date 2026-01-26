#!/usr/bin/env bash
set -euo pipefail

mkdir -p projects/01_ireland_driving_test/data/raw

# CSO PxStat API (CSV)
# ROA37: Driving Test Waiting Time
curl -L "https://ws.cso.ie/public/api.restful/PxStat.Data.Cube_API.ReadDataset/ROA37/CSV/1.0/en" \
  -o "projects/01_ireland_driving_test/data/raw/ROA37_waiting_time.csv"

# ROA31: Driving Tests Delivered and Pass Rate
curl -L "https://ws.cso.ie/public/api.restful/PxStat.Data.Cube_API.ReadDataset/ROA31/CSV/1.0/en" \
  -o "projects/01_ireland_driving_test/data/raw/ROA31_pass_rate.csv"

echo "Downloaded files:"
ls -lh projects/01_ireland_driving_test/data/raw
