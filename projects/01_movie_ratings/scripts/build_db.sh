#!/usr/bin/env bash
set -e

DB_PATH="../data/movies.db"
DATA_DIR="../data/ml-latest-small"

echo "Building SQLite database..."

sqlite3 "$DB_PATH" <<EOF
.mode csv
.import $DATA_DIR/movies.csv movies
.import $DATA_DIR/ratings.csv ratings
.import $DATA_DIR/tags.csv tags
.import $DATA_DIR/links.csv links
EOF

echo "Database build completed."
