# Client snippets for WebRTC (aerocaller)

## Static credentials (lt-cred-mech)
```js
const iceServers = [
  { urls: "stun:nxcore:3478" },
  { urls: "turn:nxcore:3478?transport=udp", username: "auser", credential: "apass" },
  { urls: "turn:nxcore:3478?transport=tcp", username: "auser", credential: "apass" },
  // If you enable TLS on 5349:
  // { urls: "turns:nxcore:5349", username: "auser", credential: "apass" },
];
const pc = new RTCPeerConnection({ iceServers });
```

## Shared-secret (use-auth-secret)
Server (coturn) started with `--use-auth-secret --static-auth-secret=...`. Generate on server or trusted context:

```bash
node generate_turn_cred.js CHANGE_ME_TO_32_HEX_CHARS 3600
# -> {"username":"<unix_ts>", "credential":"<base64_hmac_sha1>"}
```

Use in client:
```js
const cred = /* fetch from your server */ { username: "...", credential: "..." };
const iceServers = [
  { urls: "stun:nxcore:3478" },
  { urls: "turn:nxcore:3478?transport=udp", username: cred.username, credential: cred.credential },
  { urls: "turn:nxcore:3478?transport=tcp", username: cred.username, credential: cred.credential },
];
```

## Testing tip
Open `chrome://webrtc-internals` and confirm candidates. If you see `typ relay` in selected pair, TURN is in use.
