#!/bin/bash

# Moonbeam Database Migration Runner
# This script runs all migrations in order

# Configuration
SUPABASE_URL=${SUPABASE_URL:-""}
SUPABASE_KEY=${SUPABASE_KEY:-""}

# Check if required environment variables are set
if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_KEY" ]; then
  echo "Error: SUPABASE_URL and SUPABASE_KEY environment variables must be set."
  echo "Example usage:"
  echo "  SUPABASE_URL=https://your-project-id.supabase.co SUPABASE_KEY=your-anon-key ./run_migrations.sh"
  exit 1
fi

# Function to run a migration file
run_migration() {
  local file=$1
  local version=$(basename "$file" .sql)
  
  echo "Running migration: $version"
  
  # Check if migration has already been applied
  local check_result=$(curl -s -X POST \
    -H "apikey: $SUPABASE_KEY" \
    -H "Authorization: Bearer $SUPABASE_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"query\": \"SELECT version FROM schema_migrations WHERE version = '$version'\"}" \
    "$SUPABASE_URL/rest/v1/rpc/sql")
  
  if [[ $check_result == *"$version"* ]]; then
    echo "  Migration $version already applied, skipping."
    return 0
  fi
  
  # Run the migration
  local sql_content=$(cat "$file")
  local result=$(curl -s -X POST \
    -H "apikey: $SUPABASE_KEY" \
    -H "Authorization: Bearer $SUPABASE_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"query\": \"$sql_content\"}" \
    "$SUPABASE_URL/rest/v1/rpc/sql")
  
  if [[ $result == *"error"* ]]; then
    echo "  Error applying migration $version:"
    echo "$result"
    return 1
  else
    echo "  Successfully applied migration $version"
    return 0
  fi
}

# Main script
echo "Moonbeam Database Migration Runner"
echo "=================================="
echo "Supabase URL: $SUPABASE_URL"
echo

# Find all migration files and sort them
migration_files=($(find migrations -name "*.sql" | sort))

# Run each migration
for file in "${migration_files[@]}"; do
  run_migration "$file"
  if [ $? -ne 0 ]; then
    echo "Migration failed. Stopping."
    exit 1
  fi
done

echo
echo "All migrations completed successfully!"
echo "Database is now up to date."