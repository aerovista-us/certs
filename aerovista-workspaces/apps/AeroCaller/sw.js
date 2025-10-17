const CACHE_NAME = 'aerocaller-v2';
const ASSETS = [
  './index.staff.html',
  './app.staff.js',
  './manifest.webmanifest',
  './icon-192.png',
  './icon-256.png',
  './icon-512.png',
  './apple-touch-icon.png'
];

self.addEventListener('install', (e) => {
  e.waitUntil(caches.open(CACHE_NAME).then((c) => c.addAll(ASSETS)));
});

self.addEventListener('activate', (e) => {
  e.waitUntil(
    caches.keys().then(keys => Promise.all(keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k)))).then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', (e) => {
  const url = new URL(e.request.url);
  const key = url.pathname.replace(/.*\//, './');
  if (ASSETS.includes(key)) {
    e.respondWith(caches.match(e.request).then((r) => r || fetch(e.request)));
    return;
  }
  // network-first for app JS/HTML not listed in ASSETS to pick up updates
  if (e.request.destination === 'document' || e.request.destination === 'script') {
    e.respondWith(
      fetch(e.request).then((resp) => {
        const copy = resp.clone();
        caches.open(CACHE_NAME).then((c)=> c.put(e.request, copy));
        return resp;
      }).catch(() => caches.match(e.request))
    );
  }
});