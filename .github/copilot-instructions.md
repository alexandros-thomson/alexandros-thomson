# Kypria Shrine — PayPal IPN Discord Integration

**Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.**

This repository contains a Deno TypeScript application that handles PayPal Instant Payment Notifications (IPN) and integrates with Discord for sponsor role assignment and artifact delivery. The application serves as a bridge between PayPal payments and Discord community management.

## Working Effectively

### Environment Setup
- Install Deno runtime (v2.4.5 or later):
  ```bash
  curl -fsSL https://deno.land/x/install/install.sh | sh
  ```
  - If installation fails due to firewall/network restrictions, download manually:
  ```bash
  wget -O deno.zip https://github.com/denoland/deno/releases/latest/download/deno-x86_64-unknown-linux-gnu.zip
  unzip deno.zip
  chmod +x deno
  sudo mv deno /usr/local/bin/
  ```
  - Verify installation: `deno --version`

### Dependency Management
- **CRITICAL**: This environment has network connectivity limitations that may prevent dependency downloads from deno.land/x/ and jsr.io
- Dependencies are downloaded automatically on first run when network allows
- If network access is restricted, dependency downloads will fail with SSL/DNS errors
- **NEVER CANCEL**: Dependency downloads can take 2-5 minutes. NEVER CANCEL. Set timeout to 10+ minutes.

### Build and Validation
- **Lint the code**: `deno lint`
  - Expected: 3 known lint issues (2x require-await, 1x no-deprecated-deno-api)
  - Exit code 1 is expected due to these issues
  - Takes <1 second normally
- **Run tests**: `deno test -A`
  - Expected: "No test modules found" - repository has no tests currently
  - Takes <5 seconds
- **Type checking**: `deno check src/ipn-handler.ts`
  - **WARNING**: Will fail with network restrictions due to dependency imports
  - Expected error: "JSR package manifest for '@std/assert' failed to load"
  - Only works in environments with full internet access

### Running the Application
- **NEVER CANCEL**: Initial dependency download can take 5+ minutes. Set timeout to 15+ minutes.
- Start the server:
  ```bash
  deno run --allow-net --allow-read --unsafely-ignore-certificate-errors src/ipn-handler.ts
  ```
- **Network Issues**: If you get SSL certificate or DNS resolution errors, this indicates network restrictions
- The application listens on port 8000 when successfully started
- **Environment Variables Required** (for production):
  - `PAYPAL_VERIFY_URL` - PayPal IPN verification endpoint
  - `DISCORD_BOT_TOKEN` - Discord bot authentication token
  - `DISCORD_GUILD_ID` - Discord server ID
  - `SPONSOR_ROLE_ID` - Discord role ID for sponsors
  - `SPONSOR_LOG_CHANNEL_ID` - Discord channel for logging

### File Structure Understanding
```
src/
├── ipn-handler.ts              # Main application file
└── src/mappings/
    └── emailtodiscord.json     # Email to Discord ID mapping
public/                         # Static assets (SVGs)
.github/workflows/
├── deno.yml                    # CI workflow (lint + test)
└── sync-shrine-assets.yml      # Asset synchronization
```

## Validation Scenarios

### Manual Testing (when network allows)
- **Application startup test**:
  ```bash
  deno run --allow-net --allow-read --unsafely-ignore-certificate-errors src/ipn-handler.ts
  ```
  - Expected: "⚡️ PayPal IPN handler listening on port 8000" (when dependencies available)
  - Expected: SSL/DNS errors when network restricted
- **Basic endpoint test** (if server starts):
  ```bash
  curl -X POST http://localhost:8000/ipn -d "test=data"
  ```
  - Expected response: "IPN Not Verified" (normal for test data)
  - Verifies server accepts POST requests

### Testing Approach (for development)
- **Create integration tests** that mock external dependencies (PayPal, Discord)
- **Test JSON parsing** with sample PayPal IPN data
- **Validate email mapping** functionality separately
- **Mock HTTP responses** for PayPal verification
- **Note**: Tests requiring network imports will fail in restricted environments

### Code Quality Validation
- **ALWAYS run linting** before committing: `deno lint`
- **Expected lint issues** (exit code 1 is normal):
  - Line 26: `require-await` warning on `assignRole` function
  - Line 48: `require-await` warning on `logSponsor` function  
  - Line 62: `no-deprecated-deno-api` warning for `Deno.readAll` usage
- **Check formatting**: `deno fmt --check`
  - Expected: Formatting issues in `src/ipn-handler.ts` (shows diff of needed changes)
  - To fix: `deno fmt` (auto-formats the code)
- **Type checking limitations**: `deno check` will fail in network-restricted environments
- **JSON validation**: Use `python3 -m json.tool < file.json` to validate JSON files

### CI Validation
- CI workflow (`.github/workflows/deno.yml`) expects:
  - `deno lint` to run (exit code 1 is normal due to known issues)
  - `deno test -A` to run (will show "No test modules found")
- **CI may fail** if dependencies cannot be downloaded
- **NEVER CANCEL**: CI builds can take 3-5 minutes. Set timeout to 10+ minutes.
- **Format checking**: CI does not currently check formatting (commented out in workflow)

## Common Tasks

### Adding New Features
1. **ALWAYS validate syntax** before coding: `deno lint`
2. **Check formatting**: `deno fmt --check` (to see needed changes), `deno fmt` (to fix)
3. **Validate JSON files**: `python3 -m json.tool < filename.json`
4. **Run linting**: `deno lint` (expect exit code 1 with known issues)
5. **Test compilation locally** only in environments with full internet access

### Debugging Network Issues
- **SSL Certificate Errors**: Use `--unsafely-ignore-certificate-errors` flag
- **DNS Resolution Failures**: Indicates restricted network environment - not a code issue
- **JSR Package Failures**: Common in restricted environments, not a code issue
- **Import failures**: Check network connectivity with `curl -I https://deno.land`

### Environment Variables for Testing
Create a `.env` file for local testing (DO NOT COMMIT):
```bash
# Example environment setup (use test values)
export PAYPAL_VERIFY_URL="https://ipnpb.sandbox.paypal.com/cgi-bin/webscr"
export DISCORD_BOT_TOKEN="your_test_token_here"
export DISCORD_GUILD_ID="your_test_guild_id"
export SPONSOR_ROLE_ID="your_test_role_id" 
export SPONSOR_LOG_CHANNEL_ID="your_test_channel_id"
```
- Source with: `source .env` before running the application
- **NEVER commit real tokens or IDs to the repository**

### Modifying Email Mappings
- Edit `src/src/mappings/emailtodiscord.json`
- Format: `{"email@domain.com": "discord_user_id"}`
- **ALWAYS validate JSON syntax** before committing

## Repository Context

This is a GitHub profile repository (`alexandros-thomson/alexandros-thomson`) that doubles as a functional Discord integration service. The "shrine" terminology and Greek references are thematic elements of the project's presentation.

### Key Files Reference
- `README.md` - Profile README with SVG assets
- `SHRINE-LINEAGE.md` - Project documentation with mermaid diagrams
- `src/ipn-handler.ts` - Main PayPal IPN handler (88 lines)
- `public/*.svg` - Visual assets for the profile
- `.github/workflows/sync-shrine-assets.yml` - Automated asset sync (runs every 30 minutes)

### Timing Expectations
- **Deno installation**: 1-3 minutes (manual download method)
- **Dependency download**: 2-5 minutes (NEVER CANCEL), fails in network-restricted environments
- **Linting**: <1 second
- **Formatting check**: <1 second
- **Type checking**: Fails immediately in network-restricted environments
- **Application startup**: 1-2 minutes after dependencies cached
- **CI pipeline**: 3-5 minutes total (NEVER CANCEL)

**CRITICAL**: Always set timeouts of 15+ minutes for any operation involving network access or dependency downloads. Build failures are often due to network restrictions, not code issues.