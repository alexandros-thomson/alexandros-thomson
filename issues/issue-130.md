# Issue #130: Update Auth0 Dashboard Application Settings

**Phase:** Phase 1 - Core Infrastructure
**Milestone:** Auth0 deployment and security hardening
**Labels:** `auth0`, `phase-1`, `security`, `configuration`
**Priority:** Critical

## Overview

Configure the Kypria Native App in Auth0 Dashboard with production-ready settings, including callback URLs, CORS origins, token expiration, and branding assets.

## Current State

- Application exists: `Kypria Native App`
- Client ID: `sklAZUaVS44EyWD8LgyDFuhQ9ovgHYeg`
- Client Secret: Stored in GitHub Actions secrets ✓
- **Missing:** Updated callback URLs, CORS configuration, logo, token settings

## Required Changes

### 1. Basic Information
- **Name:** Kypria Native App ✓ (already set)
- **Description:** `Kypria mobile client for secure access to the Temple platform.`
- **Logo URL:** `https://kypria.com/assets/logo.png` (150×150px PNG/SVG)
- **Type:** Native ✓ (do not change)
- **Ownership:** First-party ✓ (do not change)

### 2. Application URIs - Allowed Callback URLs
Replace existing with:
```
https://myapp.org/callback,
https://auth.kypria.com/callback,
http://localhost:3000/callback,
com.kypria.app://genai-10284842558023066.us.auth0.com/ios/com.kypria.app/callback,
com.kypria.app://genai-10284842558023066.us.auth0.com/android/com.kypria.app/callback
```

**Rationale:**
- Production app callback
- Custom Auth0 domain callback (configured in #131)
- Local development/testing
- iOS native app callback
- Android native app callback

### 3. Application URIs - Allowed Logout URLs
```
https://myapp.org/logout,
https://auth.kypria.com/logout
```

### 4. Application URIs - Allowed Web Origins (CORS)
```
https://myapp.org,
https://auth.kypria.com,
http://localhost:3000
```

**Purpose:** Enables Cross-Origin Authentication for native apps + web hybrid flows.

### 5. Application URIs - Allowed Origins
```
https://myapp.org,
https://auth.kypria.com,
http://localhost:3000
```

### 6. Application URIs - Fallback URL
```
https://myapp.org/login
```

**Requirement:** Must use HTTPS and be in same domain as embedded login widget.

### 7. Token Settings - ID Token Expiration
- **Value:** `36000` seconds (10 hours)
- **Rationale:** Standard for native apps; balances security with UX

### 8. Token Settings - Refresh Token Expiration (Inactivity)
- **Value:** `1296000` seconds (15 days)
- **Behavior:** Users can remain inactive for 15 days before re-authentication required

### 9. Token Settings - Refresh Token Expiration (Absolute)
- **Value:** `2592000` seconds (30 days)
- **Behavior:** Maximum lifetime of refresh token regardless of activity

### 10. Token Settings - Refresh Token Rotation
- **Status:** ENABLE
- **Reuse Interval:** `0` seconds (strict, no grace period)
- **Behavior:** Automatic reuse detection + revocation of entire token family on replay

### 11. Cross-Origin Authentication
- **Status:** ENABLE
- **Reason:** Required for native app + web hybrid scenarios

### 12. Advanced Security (Optional but Recommended)
- **Token Sender-Constraining:** Evaluate based on native client support (DPoP/mTLS)
- **PAR (Pushed Authorization Requests):** Defer to Phase 3
- **JAR (JWT-Secured Authorization Requests):** Defer to Phase 3

## Verification

After saving, verify by:

1. Navigate to **Applications > Kypria Native App > Settings**
2. Confirm all callback URLs are listed correctly
3. Test login flow: `curl -X GET "https://YOUR_AUTH0_DOMAIN/authorize?client_id=sklAZUaVS44EyWD8LgyDFuhQ9ovgHYeg&response_type=code&redirect_uri=https://myapp.org/callback&scope=openid%20profile%20email`"
4. Verify custom logo displays on Universal Login page

## Security Considerations

- ✓ No hardcoded secrets in callback URLs
- ✓ All URLs use HTTPS (except localhost for dev)
- ✓ Refresh token rotation enabled (prevents replay attacks)
- ✓ Token expiration reasonable for mobile clients
- ✓ CORS origins restricted to known domains

## Dependencies

- **Blocks:** #131 (Custom Domain Configuration), #132 (GitHub Actions Workflow)
- **Related:** #133 (Credential Validation)

## Acceptance Criteria

- [ ] All callback URLs saved in Auth0 Dashboard
- [ ] Logo URL updated and displays correctly
- [ ] Token settings match specifications above
- [ ] Refresh token rotation enabled with 0-second reuse interval
- [ ] Test login flow succeeds with new callback URL
- [ ] No console errors on Universal Login page

## Resources

- [Auth0 Applications Documentation](https://auth0.com/docs/get-started/applications)
- [OAuth 2.0 Authorization Code Flow](https://auth0.com/docs/get-started/authentication-and-authorization-flow/authorization-code-flow)
- [Refresh Token Rotation](https://auth0.com/docs/secure/tokens/refresh-tokens/refresh-token-rotation)

---

**Estimated Effort:** 30 minutes
**Owner:** @alexandros-thomson
**Status:** Ready for Implementation