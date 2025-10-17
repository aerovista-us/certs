// AeroCaller — One-Click Group Call over Tailscale (mesh)
// Enhanced: mic selector, participants count, push-to-talk, VU meter.
//
// Mesh note: ideal for ~2–8 users. For large groups, swap to an SFU later.
const ORG_PREFIX = "aerocaller-";
const DISCOVERY_INTERVAL_MS = 5000;

let peer = null;
let localStream = null;
let isJoined = false;
let discoveryTimer = null;
let pttMode = false;
let savedDeviceId = null;

// Track calls and remote audios by peerId
const activeCalls = new Map();

// UI hooks
const joinBtn = document.getElementById("joinBtn");
const leaveBtn = document.getElementById("leaveBtn");
const muteBtn  = document.getElementById("muteBtn");
const pttBtn   = document.getElementById("pttBtn");
const statusEl = document.getElementById("status");
const connectionsEl = document.getElementById("connections");
const micSelect = document.getElementById("micSelect");
const participantsEl = document.getElementById("participants");
const localMeterBar = document.getElementById("localMeter");
const volumeDial = document.getElementById("volumeDial");

function logStatus(msg) {
  statusEl.textContent = msg;
  console.log("[AeroCaller]", msg);
}

function updateParticipants() {
  const me = isJoined ? 1 : 0;
  participantsEl.textContent = String(activeCalls.size + me);
}

async function enumerateMics() {
  const devices = await navigator.mediaDevices.enumerateDevices();
  const mics = devices.filter(d => d.kind === "audioinput");
  micSelect.innerHTML = "";
  for (const d of mics) {
    const opt = document.createElement("option");
    opt.value = d.deviceId || "";
    opt.textContent = d.label || `Microphone ${micSelect.length + 1}`;
    micSelect.appendChild(opt);
  }
  if (savedDeviceId) {
    const match = Array.from(micSelect.options).find(o => o.value === savedDeviceId);
    if (match) micSelect.value = savedDeviceId;
  }
  micSelect.disabled = mics.length === 0;
}

async function getMic(deviceId) {
  if (localStream) {
    // If we already have a stream and deviceId didn't change, reuse.
    const current = localStream.getAudioTracks()[0];
    if (current && (!deviceId || current.getSettings().deviceId === deviceId)) {
      return localStream;
    }
  }
  const constraints = {
    audio: {
      echoCancellation: true,
      noiseSuppression: true,
      autoGainControl: true,
      ...(deviceId ? { deviceId: { exact: deviceId } } : {})
    }
  };
  if (localStream) {
    for (const t of localStream.getTracks()) t.stop();
  }
  localStream = await navigator.mediaDevices.getUserMedia(constraints);
  setupLocalMeter(localStream);

  // Attempt to replace tracks on existing calls
  for (const [, call] of activeCalls) {
    try {
      const sender = call.peerConnection?.getSenders?.().find(s => s.track && s.track.kind === "audio");
      const newTrack = localStream.getAudioTracks()[0];
      if (sender && newTrack) await sender.replaceTrack(newTrack);
    } catch (e) {
      console.warn("replaceTrack failed; consider re-calling peer:", call.peer, e);
    }
  }
  return localStream;
}

let audioContext, analyser, meterRaf;
function setupLocalMeter(stream) {
  if (!window.AudioContext) return;
  try {
    if (!audioContext) audioContext = new AudioContext();
    const src = audioContext.createMediaStreamSource(stream);
    analyser = audioContext.createAnalyser();
    analyser.fftSize = 512;
    src.connect(analyser);
    const data = new Uint8Array(analyser.frequencyBinCount);
    const loop = () => {
      analyser.getByteTimeDomainData(data);
      // Compute simple peak
      let peak = 0;
      for (let i=0;i<data.length;i++) {
        const v = Math.abs(data[i] - 128) / 128;
        if (v > peak) peak = v;
      }
      const pct = Math.min(100, Math.round(peak * 160)); // little hot for visibility
      localMeterBar.style.width = pct + "%";
      meterRaf = requestAnimationFrame(loop);
    };
    if (meterRaf) cancelAnimationFrame(meterRaf);
    loop();
  } catch (e) {
    console.warn("Meter setup failed:", e);
  }
}

function makePeerId() {
  const suffix = Math.random().toString(36).slice(2, 8);
  return `${ORG_PREFIX}${suffix}`;
}

function getBasePath() {
  try {
    // If the page is /ac/index.staff.html → return '/ac/'
    const p = location.pathname || "/";
    if (p.endsWith("/")) return p;
    const idx = p.lastIndexOf("/");
    return idx >= 0 ? p.slice(0, idx + 1) : "/";
  } catch {
    return "/";
  }
}

function peerConfig() {
  const isHttps = location.protocol === "https:";
  const port = location.port ? Number(location.port) : (isHttps ? 443 : 80);
  const basePath = getBasePath();
  return {
    host: location.hostname,
    secure: isHttps,
    port,
    // Provide only the base path; PeerJS appends '/peerjs' internally
    path: basePath,
    config: {
      iceServers: (window.__turnIceServers && Array.isArray(window.__turnIceServers)) ? window.__turnIceServers : [
        { urls: "stun:stun.l.google.com:19302" }
      ]
    },
    debug: 2
  };
}

async function loadTurnConfigIfPresent() {
  try {
    const base = getBasePath();
    const url = base.endsWith('/') ? base + 'turn.json' : base + '/turn.json';
    const res = await fetch(url, { cache: 'no-store' });
    if (res.ok) {
      const data = await res.json();
      if (data && Array.isArray(data.iceServers)) {
        window.__turnIceServers = data.iceServers;
        console.log('[AeroCaller] TURN config loaded');
      }
    }
  } catch (e) {
    // no-op; keep STUN-only fallback
  }
}

function renderConnections() {
  connectionsEl.innerHTML = "";
  for (const [id, call] of activeCalls) {
    const card = document.createElement("div");
    card.className = "card";
    const title = document.createElement("div");
    title.textContent = id;
    title.style.fontWeight = "600";

    const audio = call.__audioEl || document.createElement("audio");
    audio.autoplay = true;
    audio.controls = true;
    if (typeof window.__globalVolume === 'number') {
      audio.volume = Math.max(0, Math.min(1, window.__globalVolume));
    }
    if (!call.__audioEl) {
      call.__audioEl = audio;
    }

    const row = document.createElement("div");
    row.style.display = "flex";
    row.style.gap = "8px";
    row.style.marginTop = "8px";

    const closeBtn = document.createElement("button");
    closeBtn.textContent = "Disconnect";
    closeBtn.className = "secondary";
    closeBtn.onclick = () => {
      call.close();
      activeCalls.delete(id);
      renderConnections();
      updateParticipants();
    };

    row.appendChild(closeBtn);
    card.appendChild(title);
    card.appendChild(audio);
    card.appendChild(row);
    connectionsEl.appendChild(card);
  }
  updateParticipants();
}

async function placeCall(peerId) {
  if (activeCalls.has(peerId)) return;
  await getMic(savedDeviceId);
  const call = peer.call(peerId, localStream);
  wireCallEvents(call);
}

function wireCallEvents(call) {
  activeCalls.set(call.peer, call);

  call.on("stream", (remoteStream) => {
    call.__audioEl = call.__audioEl || document.createElement("audio");
    call.__audioEl.autoplay = true;
    call.__audioEl.controls = true;
    call.__audioEl.srcObject = remoteStream;
    // apply global volume if set
    if (typeof window.__globalVolume === 'number') {
      call.__audioEl.volume = Math.max(0, Math.min(1, window.__globalVolume));
    }
    renderConnections();
  });

  call.on("close", () => {
    activeCalls.delete(call.peer);
    renderConnections();
  });

  call.on("error", (err) => {
    console.warn("Call error:", err);
    activeCalls.delete(call.peer);
    renderConnections();
  });

  renderConnections();
}

function startDiscovery() {
  stopDiscovery();
  discoveryTimer = setInterval(() => {
    if (!peer || !peer.listAllPeers) return;
    try {
      peer.listAllPeers((all) => {
        const staffPeers = all.filter(id => id.startsWith(ORG_PREFIX) && id !== peer.id);
        staffPeers.forEach(id => {
          if (!activeCalls.has(id)) placeCall(id);
        });
      });
    } catch (e) {
      console.warn("Discovery error:", e);
    }
  }, DISCOVERY_INTERVAL_MS);
}
function stopDiscovery() {
  if (discoveryTimer) {
    clearInterval(discoveryTimer);
    discoveryTimer = null;
  }
}

async function joinStaffCall() {
  if (isJoined) return;
  isJoined = true;
  joinBtn.disabled = true;
  leaveBtn.disabled = false;
  muteBtn.disabled = false;
  pttBtn.disabled = false;
  micSelect.disabled = false;

  // Persist mic choice
  savedDeviceId = localStorage.getItem("aerocaller_deviceId") || null;

  logStatus("Starting…");
  await getMic(savedDeviceId);
  await enumerateMics();

  // Load optional TURN config before creating the Peer
  await loadTurnConfigIfPresent();

  peer = new Peer(makePeerId(), peerConfig());

  peer.on("open", () => {
    logStatus(`Joined as ${peer.id}. Connecting to staff…`);
    startDiscovery();
    updateParticipants();
  });

  peer.on("call", async (call) => {
    await getMic(savedDeviceId);
    call.answer(localStream);
    wireCallEvents(call);
  });

  peer.on("error", (err) => {
    logStatus(`Peer error: ${err.type || err.message}`);
  });

  peer.on("disconnected", () => {
    logStatus("Disconnected. Reconnecting…");
    try { peer.reconnect(); } catch {}
  });

  peer.on("close", () => {
    logStatus("Peer closed.");
  });

  // If PTT is on, keep muted until pressed
  applyTalkState();
}

function leaveStaffCall() {
  stopDiscovery();
  for (const [, call] of activeCalls) {
    try { call.close(); } catch {}
  }
  activeCalls.clear();
  renderConnections();

  try { if (peer && !peer.destroyed) peer.destroy(); } catch {}
  peer = null;

  if (localStream) {
    for (const track of localStream.getTracks()) track.stop();
    localStream = null;
  }
  if (meterRaf) cancelAnimationFrame(meterRaf);

  isJoined = false;
  joinBtn.disabled = false;
  leaveBtn.disabled = true;
  muteBtn.disabled = true;
  pttBtn.disabled = true;
  micSelect.disabled = true;
  logStatus("Left call.");
  updateParticipants();
}

function setMuted(on) {
  if (!localStream) return;
  const t = localStream.getAudioTracks()[0];
  if (!t) return;
  t.enabled = !on;
  muteBtn.textContent = t.enabled ? "Mute" : "Unmute";
}

function applyTalkState() {
  if (!localStream) return;
  if (pttMode) {
    // PTT on: default muted
    setMuted(true);
    pttBtn.textContent = "PTT: On";
  } else {
    // PTT off: leave as-is
    pttBtn.textContent = "PTT: Off";
  }
}

// UI wiring
joinBtn.addEventListener("click", joinStaffCall);
leaveBtn.addEventListener("click", leaveStaffCall);

muteBtn.addEventListener("click", () => {
  if (!localStream) return;
  const t = localStream.getAudioTracks()[0];
  if (!t) return;
  t.enabled = !t.enabled;
  muteBtn.textContent = t.enabled ? "Mute" : "Unmute";
});

pttBtn.addEventListener("click", () => {
  pttMode = !pttMode;
  applyTalkState();
});

// Spacebar PTT (hold to talk when PTT enabled)
window.addEventListener("keydown", (e) => {
  if (e.code === "Space" && isJoined && localStream && pttMode) {
    e.preventDefault();
    setMuted(false);
  }
});
window.addEventListener("keyup", (e) => {
  if (e.code === "Space" && isJoined && localStream && pttMode) {
    e.preventDefault();
    setMuted(true);
  }
});

micSelect.addEventListener("change", async () => {
  savedDeviceId = micSelect.value || null;
  localStorage.setItem("aerocaller_deviceId", savedDeviceId || "");
  if (isJoined) {
    await getMic(savedDeviceId);
    applyTalkState();
  }
});

navigator.mediaDevices?.addEventListener?.("devicechange", async () => {
  await enumerateMics();
});

// Global volume controller wired from index page dial
window.__globalVolume = 0.7;
window.setGlobalCallVolume = function setGlobalCallVolume(vol){
  const clamped = Math.max(0, Math.min(1, Number(vol) || 0));
  window.__globalVolume = clamped;
  for (const [, call] of activeCalls) {
    const audio = call.__audioEl;
    if (audio) audio.volume = clamped;
  }
};

// Initialize from dial if present
try{
  if (volumeDial) {
    const v = Number(volumeDial.value || 70)/100;
    window.setGlobalCallVolume(v);
  }
}catch{}