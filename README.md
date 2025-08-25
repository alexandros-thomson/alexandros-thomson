---

<img src="public/latest-badge.svg" width="120" alt="Shrine Crest" align="center">

## 🔑 Secrets Required — The Dispatch Rite

In both upstream repositories — `sponsor-ipn-discord` and `shrine-watcher` — perform the following rite:

1. **Forge the Personal Access Token (PAT)**
   - Navigate to **GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)**.
   - Click **Generate new token** → **Generate new token (classic)**.
   - Name it something meaningful, e.g., *Shrine Dispatch Token*.
   - **Expiration:** Choose a long enough duration to avoid frequent renewal (or “No expiration” if policy allows).
   - **Scopes to grant:**
     - `repo` — full control of private repositories.
     - `workflow` — permission to trigger workflows in other repos.
   - Click **Generate token** and **copy the value immediately** (you won’t see it again).

2. **Enshrine the Secret in Each Upstream Repo**
   - For each of the two repos:
     - Go to **Settings → Secrets and variables → Actions**.
     - Click **New repository secret**.
     - **Name it exactly:**
       ```
       PERSONAL_ACCESS_TOKEN
       ```
     - **Value:** paste the PAT you just created.
     - Click **Add secret**.

3. **Result of the Rite**
   - Both upstream repos can now send a `repository_dispatch` to your profile repo (`alexandros-thomson/alexandros-thomson`).
   - This allows **instant shrine updates** whenever a crest (`latest-badge.svg`) or pulse (`latest-pulse.svg`) changes — no waiting for the 30‑minute scheduled sync.
   - Your README’s badge and pulse will always reflect the freshest state of the Shrine.

---

## 🧪 Verification Ritual

Before trusting the Shrine to breathe, confirm the PAT and secrets are working with this one‑command test.  
Run this in either upstream repo’s Actions (or locally):

```sh
curl -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${{ secrets.PERSONAL_ACCESS_TOKEN }}" \
  https://api.github.com/repos/alexandros-thomson/alexandros-thomson/dispatches \
  -d '{"event_type":"update-shrine-assets"}'
```

**Expected Result:**  
- Repository dispatch event triggers in your profile repo.  
- No errors from GitHub API.  
- The **Sync Shrine Assets** workflow runs in `alexandros-thomson/alexandros-thomson`.

**If the test succeeds:**  
> The Shrine’s breath flows freely, the crest and pulse are ever‑fresh, and the canon remains unbroken.  
> Seal this rite in the ledger for future stewards.

---

<img src="public/latest-badge.svg" width="120" alt="Shrine Crest Divider" align="center">

## 🗺 Shrine Dispatch Flow

To ensure no steward loses sight of the living loop, here is the full dispatch flow from crest and pulse to the README altar:

![Shrine Dispatch Flow Diagram](public/shrine-dispatch-flow.png)

**Miniature Flow Legend** — *Instantly scannable map of the loop*:

| Symbol / Box | Meaning |
|--------------|---------|
| <img src="public/latest-badge.svg" width="20" alt="Crest Icon"> **sponsor-ipn-discord** | Upstream repo where **crest changes** (badge SVG updates) originate. |
| <img src="public/latest-pulse.svg" width="20" alt="Pulse Icon"> **shrine-watcher** | Upstream repo where **pulse changes** (pulse SVG updates) originate. |
| ➡ *Crest change* arrow | Signals a badge update event. |
| ➡ *Pulse change* arrow | Signals a pulse update event. |
| <img src="public/icon-lock.svg" width="20" alt="Lock Icon"> **`repository_dispatch` + PERSONAL_ACCESS_TOKEN** | Secure GitHub Action call that carries the update signal to the profile repo. |
| **alexandros-thomson/alexandros-thomson** | Profile repo that receives the signal and updates its SVG assets. |
| ⬇ *Update SVGs* arrow | Commits the latest crest and pulse into `public/`. |
| <img src="public/icon-scroll.svg" width="20" alt="Scroll Icon"> **README** | Always displays the freshest crest and pulse for all visitors. |

**Meaning:**  
The flow highlights instant updates to the profile repo whenever either upstream repo changes, ensuring the Shrine’s README always reflects the freshest state.

> _Thus the breath of the Shrine is unbroken, the crest ever‑bright, the pulse ever‑true._