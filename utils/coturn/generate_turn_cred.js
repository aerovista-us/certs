// Generate short-lived TURN credential using use-auth-secret (HMAC-SHA1)
// Usage: node generate_turn_cred.js <static_secret> [ttl_seconds]
import crypto from "crypto";

const secret = process.argv[2] || "CHANGE_ME_TO_32_HEX_CHARS";
const ttl = parseInt(process.argv[3] || "3600", 10);

const username = Math.floor(Date.now() / 1000) + ttl; // UNIX timestamp in future
const hmac = crypto.createHmac("sha1", secret).update(String(username)).digest("base64");

console.log(JSON.stringify({ username: String(username), credential: hmac }, null, 2));
