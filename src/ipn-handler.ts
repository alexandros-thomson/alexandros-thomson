import { Application, Router } from "https://deno.land/x/oak/mod.ts";

// Load env vars
const {
  PAYPAL_VERIFY_URL,
  DISCORD_BOT_TOKEN,
  DISCORD_GUILD_ID,
  SPONSOR_ROLE_ID,
  SPONSOR_LOG_CHANNEL_ID,
} = Deno.env.toObject();

// Simple email→Discord mapping
const emailMap: Record<string, string> = JSON.parse(
  await Deno.readTextFile("./src/mappings/email_to_discord.json")
);

async function verifyIPN(body: string) {
  const res = await fetch(PAYPAL_VERIFY_URL, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: `cmd=_notify-validate&${body}`,
  });
  return res.text();
}

async function assignRole(discordId: string) {
  const url = `https://discord.com/api/guilds/${DISCORD_GUILD_ID}/members/${discordId}/roles/${SPONSOR_ROLE_ID}`;
  return fetch(url, { method: "PUT", headers: { Authorization: `Bot ${DISCORD_BOT_TOKEN}` } });
}

async function dropArtifact(discordId: string, item: string) {
  // open DM
  const dmRes = await fetch("https://discord.com/api/users/@me/channels", {
    method: "POST",
    headers: { "Authorization": `Bot ${DISCORD_BOT_TOKEN}`, "Content-Type": "application/json" },
    body: JSON.stringify({ recipient_id: discordId }),
  });
  const dm = await dmRes.json();
  const vaultUrl = `https://vault.kypria.com/artifacts/${item}/${discordId}`;
  // send link
  return fetch(`https://discord.com/api/channels/${dm.id}/messages`, {
    method: "POST",
    headers: { "Authorization": `Bot ${DISCORD_BOT_TOKEN}`, "Content-Type": "application/json" },
    body: JSON.stringify({ content: `Your artifact awaits: ${vaultUrl}` }),
  });
}

async function logSponsor(discordId: string, item: string, txn: string) {
  const msg = {
    content: `🎉 New Sponsor: <@${discordId}> pledged for **${item}** (txn ${txn})`,
  };
  return fetch(
    `https://discord.com/api/channels/${SPONSOR_LOG_CHANNEL_ID}/messages`,
    { method: "POST", headers: { "Authorization": `Bot ${DISCORD_BOT_TOKEN}`, "Content-Type": "application/json" }, body: JSON.stringify(msg) }
  );
}

const app = new Application();
const router = new Router();

router.post("/ipn", async (ctx) => {
  const raw = new TextDecoder().decode(await Deno.readAll(ctx.request.body({ type: "reader" }).value));
  const verification = await verifyIPN(raw);
  if (verification !== "VERIFIED") {
    ctx.response.status = 400;
    ctx.response.body = "IPN Not Verified";
    return;
  }

  const params = new URLSearchParams(raw);
  const email = params.get("payer_email")!;
  const item  = params.get("item_name")!;
  const txn   = params.get("txn_id")!;
  const discordId = emailMap[email];

  await assignRole(discordId);
  await dropArtifact(discordId, item);
  await logSponsor(discordId, item, txn);

  ctx.response.status = 200;
  ctx.response.body = "OK";
});

app.use(router.routes());
app.use(router.allowedMethods());

console.log("⚡️ PayPal IPN handler listening on port 8000");
await app.listen({ port: 8000 });