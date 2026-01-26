# Ireland Driving Test SQL Analysis (Planned)

## Goal
Use CSO public datasets to analyze:
- driving test waiting times by test centre / county / time
- driving test pass rates by test centre / time
- whether longer waits are associated with different pass rates (exploratory)

## Data
- ROA37: Driving Test Waiting Time (CSO)
- ROA31: Driving Tests Delivered and Pass Rate (CSO)

## Plan
1) Download data via terminal (scripted)
2) Build SQLite database (scripted)
3) Clean + standardize centre names and time periods
4) Create relational tables (centres, periods, waiting_times, pass_rates)
5) Run analysis queries and export summary tables

## Run (coming next)
- `./scripts/download_data.sh`
- `./scripts/build_db.sh`

