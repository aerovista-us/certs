/**
 * server.staff.js — branded
 * Serves static files and PeerJS signaling with discovery enabled.
 */
const fs = require('fs');
const http = require('http');
const https = require('https');
const express = require('express');
const { ExpressPeerServer } = require('peer');

const USE_HTTPS = process.env.USE_HTTPS === '1';
const PORT = Number(process.env.PORT || 8443);
const BIND_ADDR = process.env.BIND_ADDR || '0.0.0.0';
const BASE_PATH_RAW = process.env.BASE_PATH || '/';
const BASE_PATH_NORM = BASE_PATH_RAW.startsWith('/') ? BASE_PATH_RAW : `/${BASE_PATH_RAW}`;
const BASE_PATH = BASE_PATH_NORM.endsWith('/') ? BASE_PATH_NORM : `${BASE_PATH_NORM}/`;
const KEY_PATH = process.env.KEY_PATH || '';
const CERT_PATH = process.env.CERT_PATH || '';

const app = express();

// Serve at root
app.use(express.static(__dirname));
app.get('/', (_req, res) => res.redirect('/index.staff.html'));
app.get('/api/readyz', (_req, res) => res.status(200).json({ ok: true }));

// Optionally also serve under BASE_PATH (for reverse proxies that don't strip prefixes)
if (BASE_PATH !== '/') {
  app.use(BASE_PATH, express.static(__dirname));
  app.get(BASE_PATH, (_req, res) => res.redirect(`${BASE_PATH}index.staff.html`));
  app.get(`${BASE_PATH}api/readyz`, (_req, res) => res.status(200).json({ ok: true }));
}

let server;
if (USE_HTTPS) {
  if (!KEY_PATH || !CERT_PATH) {
    console.error('When USE_HTTPS=1, set KEY_PATH and CERT_PATH env vars.');
    process.exit(1);
  }
  server = https.createServer({
    key: fs.readFileSync(KEY_PATH),
    cert: fs.readFileSync(CERT_PATH)
  }, app);
} else {
  server = http.createServer(app);
}

// Configure PeerJS to expose endpoints under '/peerjs' relative to whatever mount base we use
const peerServer = ExpressPeerServer(server, { path: '/peerjs', allow_discovery: true });

// Mount PeerJS at root (/) so effective WS endpoint is '/peerjs'
app.use('/', peerServer);
// And at BASE_PATH so effective WS endpoint is `${BASE_PATH}peerjs`
if (BASE_PATH !== '/') app.use(BASE_PATH, peerServer);

server.listen(PORT, BIND_ADDR, () => {
  const host = BIND_ADDR === '0.0.0.0' ? '0.0.0.0' : BIND_ADDR;
  console.log(`[staff] listening on ${USE_HTTPS ? 'https' : 'http'}://${host}:${PORT}`);
  console.log(`[staff] base paths: '/'${BASE_PATH !== '/' ? ` and '${BASE_PATH}'` : ''}`);
  console.log(`[staff] open: http://localhost:${PORT}${BASE_PATH}index.staff.html`);
});