# Dependency Update Instructions

## Current Status

The `mix.exs` file has been updated with new version constraints to allow upgrading to the latest versions of Elixir dependencies. However, due to network connectivity restrictions in the current environment (DNS resolution failures for repo.hex.pm), the `mix.lock` file could not be automatically updated.

## What Was Changed

### Updated Version Constraints in `mix.exs`:

1. **phoenix**: `~> 1.7.18` → `~> 1.8`
   - Allows upgrade from 1.7.21 to 1.8.3+
   
2. **phoenix_live_view**: `~> 1.0.1` → `~> 1.1`
   - Allows upgrade from 1.0.17 to 1.1.22+
   
3. **dns_cluster**: `~> 0.1.1` → `~> 0.2`
   - Allows upgrade from 0.1.3 to 0.2.0+
   
4. **usage_rules**: `~> 0.1` → `~> 1.0`
   - Allows upgrade from 0.1.24 to 1.0.3+

5. **gettext**: Kept at `~> 0.26`
   - Cannot upgrade to 1.0 because the `langchain` dependency requires `gettext ~> 0.20`

## How to Complete the Update

### Option 1: Manual Command-Line Update (Recommended)

Run the following commands in an environment with proper network connectivity (local development machine or CI):

```bash
cd valentine

# First, unlock the dependencies that need version updates
mix deps.unlock dns_cluster phoenix phoenix_live_view usage_rules

# Update all dependencies to their latest allowed versions
mix deps.update --all

# Fetch any new dependencies
mix deps.get

# Compile and verify there are no warnings
mix compile --warnings-as-errors

# Format the code
mix format

# Run tests to ensure everything still works
MIX_ENV=test mix test
```

### Option 2: Use the Helper Script

```bash
# From the repository root
./scripts/update-elixir-deps.sh
```

### Option 3: Trigger GitHub Actions Workflow

The GitHub Actions workflow at `.github/workflows/update-deps.yml` can be manually triggered to automatically perform the update and create a pull request with the changes.

## Expected Dependency Updates

Based on `mix hex.outdated` output, these direct dependencies will be updated:

### Safe Updates (no breaking changes):
- bandit: 1.7.0 → 1.10.2
- cachex: 4.1.0 → 4.1.1
- ecto_sql: 3.13.2 → 3.13.4
- finch: 0.19.0 → 0.21.0
- guardian: 2.3.2 → 2.4.0
- mdex: 0.7.3 → 0.11.3
- phoenix_ecto: 4.6.5 → 4.7.0
- phoenix_html: 4.2.1 → 4.3.0
- phoenix_live_reload: 1.6.0 → 1.6.2
- postgrex: 0.20.0 → 0.22.0
- sobelow: 0.14.0 → 0.14.1
- swoosh: 1.19.3 → 1.21.0
- telemetry_poller: 1.2.0 → 1.3.0
- ueberauth_microsoft: 0.24.0 → 0.25.0

### With Version Constraint Updates (potentially breaking):
- dns_cluster: 0.1.3 → 0.2.0
- phoenix: 1.7.21 → 1.8.3
- phoenix_live_view: 1.0.17 → 1.1.22
- usage_rules: 0.1.24 → 1.0.3

### Many transitive dependencies will also be updated

## Alternative: Use GitHub Actions

A GitHub Actions workflow has been created at `.github/workflows/update-deps.yml` that can automatically run the dependency update in CI and create a pull request with the changes. You can trigger it manually or it will run weekly.

## Alternative: Use the Helper Script

Run the helper script that has been created:

```bash
./scripts/update-elixir-deps.sh
```

This script will:
1. Show outdated dependencies
2. Update all dependencies
3. Compile with warnings as errors
4. Format the code
5. Run tests

## Troubleshooting

If you encounter compilation errors after updating:

1. Check the changelog for each package with a major version bump
2. Look for migration guides:
   - Phoenix 1.8: https://hexdocs.pm/phoenix/1.8.0/changelog.html
   - Phoenix LiveView 1.1: https://hexdocs.pm/phoenix_live_view/1.1.0/changelog.html
   - Usage Rules 1.0: Check package documentation

3. Most updates should be backward compatible within the same major version

## Network Issue Details

The current environment experiences DNS resolution failures when trying to reach `repo.hex.pm`:
```
{:failed_connect, [{:to_address, {~c"repo.hex.pm", 443}}, {:inet, [:inet], :nxdomain}]}
```

This is why the lock file could not be updated automatically. Running the commands above in a properly networked environment (local development, CI/CD) will resolve this issue.
