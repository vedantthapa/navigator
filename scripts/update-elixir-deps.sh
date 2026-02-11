#!/usr/bin/env bash
#
# Script to update Elixir dependencies
# This script should be run in an environment with network access to repo.hex.pm
#

set -e

cd "$(dirname "$0")/../valentine"

echo "Updating Elixir dependencies..."
echo "==============================="
echo ""

echo "Step 1: Fetching latest dependency information..."
mix hex.outdated

echo ""
echo "Step 2: Updating all dependencies to latest versions..."
mix deps.update --all

echo ""
echo "Step 3: Getting updated dependencies..."
mix deps.get

echo ""
echo "Step 4: Compiling with warnings as errors..."
mix compile --warnings-as-errors

echo ""
echo "Step 5: Running formatter..."
mix format

echo ""
echo "Step 6: Running tests..."
mix test

echo ""
echo "Dependency update complete!"
echo "Review the changes to mix.lock and commit if everything looks good."
