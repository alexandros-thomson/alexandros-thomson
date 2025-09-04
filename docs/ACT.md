# Local GitHub Actions Testing with Act

This repository supports local testing of GitHub Actions workflows using [nektos/act](https://github.com/nektos/act).

## Installation

### Install act

```bash
# Install act using the official installer
curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | bash
```

This will install act to `./bin/act` in the repository root.

### Install Docker

Act requires Docker to be installed and running on your system.

## Usage

### List available jobs

```bash
# List all jobs in all workflows
./bin/act --list

# List jobs in a specific workflow
./bin/act --list -W .github/workflows/main.yml
./bin/act --list -W .github/workflows/deno.yml
```

### Run specific jobs

```bash
# Run the test job from main.yml
./bin/act -j test -W .github/workflows/main.yml

# Run the lint job from main.yml  
./bin/act -j lint -W .github/workflows/main.yml

# Run the Deno test job
./bin/act -j test -W .github/workflows/deno.yml
```

### Run all jobs in a workflow

```bash
# Run all jobs in main workflow
./bin/act -W .github/workflows/main.yml

# Run all jobs in Deno workflow
./bin/act -W .github/workflows/deno.yml
```

## Available Jobs

### Main CI Workflow (`main.yml`)
- **test**: Runs Deno linting and tests
- **lint**: Runs Deno formatting check and linting

### Deno Workflow (`deno.yml`)
- **test**: Runs Deno linting and tests

### Docker Workflow (`docker-publish.yml`)
- **build**: Builds and publishes Docker image

## Configuration

The repository includes a `.actrc` configuration file with recommended settings:
- Uses `catthehacker/ubuntu:act-22.04` runner image for better compatibility
- Enables verbose output for debugging
- Configures bind mounts

## Environment Variables

Some workflows may require environment variables. Create a `.env` file in the repository root:

```bash
# Example .env file (for PayPal IPN handler)
PAYPAL_VERIFY_URL=https://ipnpb.sandbox.paypal.com/cgi-bin/webscr
DISCORD_BOT_TOKEN=your_bot_token_here
DISCORD_GUILD_ID=your_guild_id_here
SPONSOR_ROLE_ID=your_role_id_here
SPONSOR_LOG_CHANNEL_ID=your_channel_id_here
```

## Examples

```bash
# Test the main CI workflow locally
./bin/act -j test -W .github/workflows/main.yml

# Run only linting
./bin/act -j lint -W .github/workflows/main.yml

# Test Deno workflow (equivalent to above test job)
./bin/act -j test -W .github/workflows/deno.yml

# Run with specific event (push)
./bin/act push -j test -W .github/workflows/main.yml
```

## Troubleshooting

1. **Docker not running**: Ensure Docker daemon is running
2. **Permission denied**: Make sure `./bin/act` is executable: `chmod +x ./bin/act`
3. **Network issues**: Some workflows may require internet access
4. **Large images**: First run may take time to download Docker images
5. **Missing secrets**: Add required secrets to `.secrets` file

## Notes

- The `bin/act` binary is excluded from git via `.gitignore`
- Act runs workflows in Docker containers, so performance may vary
- Some GitHub-specific features may not work identically in local environment