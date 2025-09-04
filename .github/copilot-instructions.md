# PayPal IPN → Discord Integration Service

PayPal Instant Payment Notification (IPN) handler written in Deno that processes payments and integrates with Discord by assigning roles, sending direct messages, and logging sponsor activities to channels.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

### Bootstrap and Setup
- **Install Deno runtime**: 
  ```bash
  wget https://github.com/denoland/deno/releases/latest/download/deno-x86_64-unknown-linux-gnu.zip
  unzip deno-x86_64-unknown-linux-gnu.zip
  chmod +x deno
  sudo mv deno /usr/local/bin/
  ```
  Takes ~3 seconds. Verify with `deno --version`.

- **Environment Variables Required** (all mandatory):
  ```bash
  export PAYPAL_VERIFY_URL="https://ipnpb.sandbox.paypal.com/cgi-bin/webscr"  # or production URL
  export DISCORD_BOT_TOKEN="your_bot_token_here"
  export DISCORD_GUILD_ID="your_guild_id_here" 
  export SPONSOR_ROLE_ID="your_sponsor_role_id_here"
  export SPONSOR_LOG_CHANNEL_ID="your_log_channel_id_here"
  ```

### Build and Validation Commands
- **Lint the code**: `deno lint` -- takes ~1 second. KNOWN ISSUES: Currently finds 3 lint problems (deprecated Deno.readAll API, async functions without await).
- **Format code**: `deno fmt src/ipn-handler.ts` -- takes ~0.012 seconds. Use `deno fmt --check` to preview changes without applying.
- **Type checking**: `deno check src/ipn-handler.ts` -- WILL FAIL in network-restricted environments due to certificate issues.
- **Run tests**: `deno test -A` -- takes ~0.5 seconds. Currently returns "No test modules found" (exit code 1) as no tests exist yet.

### Network Limitations and Workarounds
- **CRITICAL**: This environment has TLS certificate validation issues that prevent downloading dependencies from https://deno.land/x/oak and JSR registry.
- **Workaround available**: `--unsafely-ignore-certificate-errors` flag exists but still fails on JSR imports.
- **Impact**: Cannot run the full application or perform type checking in network-restricted environments.
- **Alternative validation**: Use the environment variable validation approach below.

### Running the Application
- **WILL FAIL in current environment** due to network restrictions. In normal environments:
  ```bash
  deno run -A src/ipn-handler.ts
  ```
- **Application details**: 
  - Listens on port 8000
  - Serves POST endpoint `/ipn` for PayPal notifications
  - Uses Oak framework (Deno equivalent of Express.js)
  - Single dependency: `https://deno.land/x/oak/mod.ts`

### Validation Scenarios (Network-Independent)
- **Quick environment validation** (runs in ~0.034 seconds):
  ```bash
  # Test all required environment variables are set
  PAYPAL_VERIFY_URL=https://ipnpb.sandbox.paypal.com/cgi-bin/webscr \
  DISCORD_BOT_TOKEN=dummy_token_12345 \
  DISCORD_GUILD_ID=123456789012345678 \
  SPONSOR_ROLE_ID=987654321098765432 \
  SPONSOR_LOG_CHANNEL_ID=555555555555555555 \
  deno eval "console.log('✅ All env vars:', Object.keys(Deno.env.toObject()).filter(k => k.startsWith('PAYPAL_') || k.startsWith('DISCORD_') || k.includes('SPONSOR')).length, 'found')"
  ```

- **Email mapping validation**:
  ```bash
  # Verify email to Discord mapping file exists and is valid JSON
  deno eval "console.log('✅ Email mapping:', JSON.parse(await Deno.readTextFile('./src/src/mappings/emailtodiscord.json')))"
  ```

- **COMPREHENSIVE business logic validation** (runs in ~0.035 seconds):
  ```bash
  # Run the provided validation script to test complete workflow
  deno run -A validate_ipn_logic.ts
  ```
  This script validates the entire business logic flow and is ESSENTIAL for ensuring code changes don't break the sponsor workflow. Tests: environment setup → IPN parsing → email mapping → Discord API URLs → message formatting.

### Common Tasks and File Locations
- **Main application**: `src/ipn-handler.ts` (88 lines)
- **Configuration**: `src/src/mappings/emailtodiscord.json` (email → Discord ID mapping)
- **Validation script**: `validate_ipn_logic.ts` (comprehensive business logic testing)
- **Workflows**: `.github/workflows/deno.yml` (official build pipeline)
- **Public assets**: SVG graphics in `public/` directory
- **Documentation**: `README.md`, `SHRINE-LINEAGE.md`

### Known Code Issues (from linting)
1. **Line 26**: `async function assignRole` has no await expression - remove `async` or add `await`
2. **Line 48**: `async function logSponsor` has no await expression - remove `async` or add `await` 
3. **Line 62**: `Deno.readAll` deprecated in Deno 2 - replace with `readAll()` from `@std/io`

### CI/CD Integration
- **Before committing**: Always run `deno fmt && deno lint` 
- **GitHub Actions**: The workflow runs `deno lint` and `deno test -A`
- **Expected failures**: Tests will fail with "No test modules found" until tests are added

### Testing Strategy
- **Unit tests**: None exist yet. Create tests in format:
  ```typescript
  Deno.test("test name", () => {
    // Test logic using basic assertions
    if (condition !== expected) throw new Error("Assertion failed");
  });
  ```
- **Business logic validation**: Use the comprehensive validation script above to test complete workflow
- **Integration testing**: Test PayPal webhook locally using tools like ngrok for tunneling
- **Manual validation scenarios**: 
  1. **Environment setup**: Verify all 5 environment variables load correctly
  2. **IPN parsing**: Test URLSearchParams parsing of PayPal notification data
  3. **Email lookup**: Validate Discord ID resolution from email mapping
  4. **Discord API URLs**: Ensure proper URL construction for role assignment and logging
  5. **Message formatting**: Verify sponsor log message includes Discord mention, item, and transaction ID
  6. **Complete flow**: Payment → IPN → Discord role assignment → DM → channel log

### Repository Context
- **Type**: Personal GitHub profile repository with PayPal/Discord integration service
- **Theme**: Greek mythological styling ("Kypria - Shrine of the Sealed Canon")  
- **Purpose**: Sponsor management system that bridges PayPal payments to Discord community perks

### Timing Expectations
- **Deno installation**: ~3 seconds
- **Deno lint**: ~0.014 seconds 
- **Deno fmt**: ~0.012 seconds
- **Deno test**: ~0.5 seconds
- **Environment validation**: ~0.034 seconds
- **Business logic validation**: ~0.035 seconds
- **NEVER CANCEL**: All commands complete within seconds. No long-running builds in this repository.

### Development Workflow
When making changes to the IPN handler:
1. **Before editing**: Run `deno fmt --check src/ipn-handler.ts` to see current formatting status
2. **After editing**: Run `deno fmt src/ipn-handler.ts && deno lint` to format and validate
3. **Before committing**: Run the comprehensive business logic validation to ensure workflow integrity
4. **Test email mappings**: Add test entries to `src/src/mappings/emailtodiscord.json` for validation

### Troubleshooting
- **"Import failed" errors**: Network/certificate issues - cannot download Oak dependency in restricted environments
- **"No test modules found"**: Expected - no tests exist yet, this is normal (exit code 1)
- **Lint errors about async/await**: Known issue - functions return Promises but don't use await internally
- **Format changes needed**: Run `deno fmt` to apply automatic formatting fixes
- **"Cannot resolve email"**: Check that email exists in `src/src/mappings/emailtodiscord.json`
- **Environment variable missing**: All 5 variables (PAYPAL_VERIFY_URL, DISCORD_BOT_TOKEN, DISCORD_GUILD_ID, SPONSOR_ROLE_ID, SPONSOR_LOG_CHANNEL_ID) are mandatory

### Quick Reference Commands
```bash
# Essential validation commands (all work offline):
deno --version                           # Verify installation
deno lint                               # Check code quality (~0.014s)
deno fmt --check src/ipn-handler.ts     # Preview format changes (~0.012s) 
deno fmt src/ipn-handler.ts             # Apply format changes (~0.012s)
deno run -A validate_ipn_logic.ts       # Test complete business logic (~0.035s)
deno eval "console.log('✅ Deno works')" # Basic runtime test (~0.035s)

# Environment and mapping validation:
deno eval "console.log('✅ Email mapping:', JSON.parse(await Deno.readTextFile('./src/src/mappings/emailtodiscord.json')))"
```