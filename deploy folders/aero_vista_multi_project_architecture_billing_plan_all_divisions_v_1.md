# AeroVista Multi‑Project Architecture & Billing Plan (All Divisions) — v1.0

_Last updated: 2025‑10‑07 (PT)_

---

## 0) Executive Summary
- **Goal:** Split AeroVista into a clean, scalable, cost‑aware **multi‑project** layout across Google Cloud & Firebase, while keeping a seamless UX (SSO, shared domains) and tight security.
- **Approach:**
  - Centralize **Identity (Firebase Auth)**, **Monitoring**, **Secrets**, and **Org‑level policies**.
  - Create **per‑division projects** + **shared infrastructure projects** (network, logging, security).
  - Use **subdomains** and **reverse proxy** where needed to present a single brand experience.
  - Implement **budgets/alerts**, **cost labels**, **Terraform IaC**, **SOPs**, and **migration playbook**.

---

## 1) Org & Billing Structure

### 1.1 Organization & Folders
```
AeroVista (GCP Organization)
└─ folders/
   ├─ shared/             # shared infra
   │  ├─ av‑auth          # central Firebase Auth project (Auth only)
   │  ├─ av‑network       # VPC, serverless connector, Cloud NAT
   │  ├─ av‑security      # SCC, KMS, Secret Manager
   │  ├─ av‑monitoring    # Cloud Logging, Metrics, Uptime, SLOs
   │  └─ av‑ci            # Artifact Registry, Cloud Build, runners
   ├─ products/           # customer‑facing apps
   │  ├─ av‑web           # main marketing / corporate site (AeroVista.us)
   │  ├─ av‑rydesync      # RydeSync app & APIs
   │  ├─ av‑bytepad       # BytePad app (if/when public)
   │  └─ av‑cx‑pulse      # CX Pulse dashboards/APIs (if hosted on GCP)
   └─ divisions/          # individual business units
      ├─ nexus            # Nexus TechWorks
      ├─ skyforge         # SkyForge Creative Studios
      ├─ echoverse        # EchoVerse Audio (media portals, assets)
      ├─ summit           # Summit Learning (LMS, content)
      ├─ vespera          # Vespera Publishing
      ├─ horizon          # Horizon Aerial & Visual
      └─ lumina           # Lumina Creative Media
```

### 1.2 Billing Accounts
- **Primary Billing Account:** `AeroVista‑Primary` (link default projects here).
- **Optional Secondary:** `AeroVista‑R&D` for experiments / labs (enables clean budget isolation & free‑tier testing).
- **Linkage:** Projects map to one billing account. Firebase/GCP **usage is per project**; payment is charged to the linked **billing account**.

### 1.3 Budgets & Alerts (per project)
- Set **monthly budget** with **threshold alerts** at 25%/50%/80%/100%.
- Enable **anomaly detection** + **Pub/Sub → Cloud Function/Run** to create Slack/Email alerts.
- Label resources: `team`, `division`, `env`, `service`, `cost_center`.

---

## 2) Domains, DNS, & Routing

### 2.1 Brand Domains
- **Primary:** `aerovista.us`
- **Subdomains (examples):**
  - `app.aerovista.us` → AV Web app (Project: `av‑web`)
  - `ryde.aerovista.us` → RydeSync (Project: `av‑rydesync`)
  - `media.aerovista.us` → EchoVerse portals (Project: `echoverse`)
  - `learn.aerovista.us` → Summit Learning (Project: `summit`)
  - `labs.aerovista.us` → R&D experiments (Project: `nexus` or `R&D`)

### 2.2 Routing Patterns
- **Simplest:** separate Hosting/Run backends per subdomain.
- **Seamless Single‑Origin UX:** reverse proxy under `aerovista.us` → route `/ryde/*` to `av‑rydesync`.
- **CDN:** Use Firebase Hosting CDN (or Cloud CDN if needed) with cache headers for static/media.

### 2.3 Firebase Hosting Rewrites (example)
```json
{
  "hosting": {
    "target": "av‑web",
    "public": "public",
    "rewrites": [
      { "source": "/api/rydesync/**", "run": { "serviceId": "rydesync‑api", "region": "us‑central1" } },
      { "source": "**", "destination": "/index.html" }
    ],
    "headers": [
      { "source": "**", "headers": [{ "key": "Strict‑Transport‑Security", "value": "max‑age=31536000; includeSubDomains; preload" }] }
    ]
  }
}
```

---

## 3) Identity & Access (SSO)

### 3.1 Strategy
- **Centralize Firebase Auth** in `av‑auth` project.
- All frontends initialize Firebase with **same Auth config** (project ID, API key, authorized domains).
- Backends verify ID tokens issued by `av‑auth`.

### 3.2 Authorized Domains
- Add: `aerovista.us`, `*.aerovista.us`, dev/stage subdomains, and localhost ports.

### 3.3 Custom Claims
- `div_echoverse`, `div_nexus`, `admin`, `staff`, `rydesyncAccess`.
- Issued by Admin SDK (Cloud Run job) on role change; cached 5–10 minutes client‑side.

### 3.4 Cross‑Project Token Verification (Node/Express)
```js
import { initializeApp, applicationDefault } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
initializeApp({ credential: applicationDefault(), projectId: 'av-auth' });

export async function verify(req, res, next) {
  const idToken = (req.headers.authorization || '').replace('Bearer ', '');
  try {
    const decoded = await getAuth().verifyIdToken(idToken, true);
    req.user = decoded; // contains custom claims
    return next();
  } catch (e) {
    return res.status(401).json({ error: 'UNAUTHORIZED' });
  }
}
```

---

## 4) Project‑by‑Division Map & Services

| Division / Product | Project ID | Frontend | Backend | Data | Notes |
|---|---|---|---|---|---|
| **AeroVista Web (Corp)** | `av‑web` | Firebase Hosting+Functions | Cloud Run `aerovista‑api` | Firestore/Storage | Marketing site, contact forms, light APIs |
| **RydeSync** | `av‑rydesync` | Hosting (or Next.js on Vercel ↔ GCP) | Cloud Run `rydesync‑api` + WebSockets + **Redis** | Firebase RTDB (metadata) | Move hot sync to Redis; keep RTDB for presence/roles |
| **EchoVerse (Media)** | `echoverse` | Hosting | Cloud Run media APIs | Cloud Storage (media), Firestore | Signed URLs, CDN cache, media processing |
| **Nexus TechWorks (Apps/Labs)** | `nexus` | Hosting for demos | Cloud Run, Cloud Functions | Firestore/BigQuery | R&D feature flags, staging envs |
| **SkyForge (Games)** | `skyforge` | Hosting (game portals) | Cloud Run game services | Firestore/Storage | Feature toggles, analytics |
| **Summit Learning** | `summit` | Hosting (LMS UI) | Cloud Run LMS API | Firestore/BigQuery | Per‑course storage, export to BQ |
| **Vespera Publishing** | `vespera` | Hosting | Cloud Run CMS API | Firestore/Storage | Publishing backend, webhooks |
| **Horizon Aerial & Visual** | `horizon` | Hosting (portfolio) | Cloud Run ingest | Storage (raw/video), Transcoder | Video pipeline, signed URLs |
| **Lumina Creative Media** | `lumina` | Hosting (portfolio/shop) | Cloud Run commerce API | Firestore/Stripe | PCI‑aware patterns (Stripe Checkout) |
| **Shared Auth** | `av‑auth` | — | Admin SDK jobs | Firebase Auth | Central SSO, custom claims |
| **Shared Net** | `av‑network` | — | — | — | VPC, nat, serverless conn |
| **Security** | `av‑security` | — | — | Secret Manager, KMS | SCC, org policies |
| **Monitoring** | `av‑monitoring` | — | — | Logging, Metrics | Central dashboards |

---

## 5) Service Choices & Defaults

- **Compute:** Cloud Run (min instances = 0 or 1 as needed for cold‑start tolerance).
- **Realtime:** **Redis (Pub/Sub)** for hot room sync; Firebase RTDB for presence/metadata.
- **Databases:** Firestore (app config, content), BigQuery (analytics), Cloud SQL (if relational needed).
- **Storage/CDN:** Firebase Hosting + Cloud Storage; signed URLs for private media.
- **Queues/Events:** Pub/Sub for async operations and fan‑out.
- **Secrets:** Secret Manager (per‑project, with shared KMS keyring in `av‑security`).

---

## 6) Security Baselines

- **Org Policies:** disable legacy APIs, enforce CMEK where required, restrict public IPs for admin surfaces.
- **IAM:** Principle of least privilege; group‑based assignments per division; custom roles for deployers vs operators.
- **WAF:** Cloud Armor for public Run endpoints (rate limit, IP allow/deny, OWASP rules).
- **Headers:** HSTS, CSP (nonce‑based for inline), `X‑Frame‑Options`, `Referrer‑Policy`.
- **AuthZ:** Custom claims gating (
  `admin`, `staff`, `div_*`, `rydesyncAccess`).
- **Audit:** SCC findings to central sink; alert on new public buckets, new allUsers bindings, or key creation.

---

## 7) Networking & CORS

### 7.1 CORS policy (Cloud Run / Express)
```js
import cors from 'cors';
const allowed = [
  'https://aerovista.us',
  'https://app.aerovista.us',
  'https://ryde.aerovista.us',
  'http://localhost:5173'
];
app.use(cors({
  origin: (origin, cb) => cb(null, !origin || allowed.includes(origin)),
  credentials: true,
}));
```

### 7.2 WebSocket Origin Check
```js
wss.on('connection', (ws, req) => {
  const origin = req.headers.origin || '';
  if (!['https://aerovista.us','https://ryde.aerovista.us'].includes(origin)) {
    ws.close(1008, 'Invalid Origin');
    return;
  }
  // ...
});
```

---

## 8) Observability

- **Logging:** Structured logs, request IDs, user claim summaries (no PII).
- **Metrics:** QPS, p95 latency, error rate, WS connect success, room fan‑out time.
- **Uptime Checks:** Public URLs + auth‑required endpoint using service account token.
- **SLOs:** 99.5% availability for public APIs; alerting at burn‑rates (1h/6h windows).

---

## 9) CI/CD & Environments

- **Branches:** `main` (prod), `staging`, `dev/*`.
- **Pipelines:** Cloud Build or GitHub Actions → deploy Hosting/Run per project.
- **Envs:** `dev`, `staging`, `prod` per product project; preview channels for Hosting.
- **Artifacts:** Artifact Registry for containers; lock base images.
- **Config:** `.env` via Secret Manager; pull at runtime with Workload Identity.

---

## 10) Cost Controls & Forecasting

- **Budgets** & alerts (Sec. 1.3).
- **Idle controls:** Cloud Run min instances `0` for low‑traffic services.
- **Redis tiers:** Start with smallest Redis Cloud tier; monitor conn/memory.
- **Data egress:** Prefer same region; serve media via CDN; compress JSON.
- **Labels:** Enforce in CI/CD; export billing to BigQuery → Looker Studio dashboard.

---

## 11) Migration Playbook

### Phase 0: Readiness
- Create `av‑auth`, add domains, migrate existing users or link providers.
- Provision `av‑rydesync` (Run + Redis) and `av‑web` (Hosting + Run).
- Set budgets, IAM, secrets.

### Phase 1: RydeSync split
- Deploy `rydesync‑api` to `av‑rydesync`.
- Implement Redis Pub/Sub; keep Firebase RTDB for presence.
- Update `av‑web` links or proxy `/api/rydesync/*` to `av‑rydesync`.
- Migrate environment vars to Secret Manager.

### Phase 2: Auth centralization
- Point all frontends to `av‑auth`. Roll out custom claims issuance.
- Update backends to verify tokens from `av‑auth`.

### Phase 3: Division projects
- Stand up EchoVerse/Summit/SkyForge/etc. projects.
- Move division assets and APIs into their projects.
- Update DNS and CDNs.

### Phase 4: Optimize & harden
- Add Cloud Armor policies; finalize CSP; tune Run concurrency.
- Enable export of logs/billing to BQ and finalize dashboards.

---

## 12) Risk Register & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|---|---|---:|---|
| Cross‑project auth mismatch | Login loops | Med | Centralize Auth, extensive staging testing |
| CORS misconfig | API failures | Med | Known allowed origins list; automated tests |
| Cost spikes (egress/Redis) | Budget overrun | Low‑Med | Budgets, alerts, cap tiers, same‑region deployments |
| DNS/SSL mis‑routing | Downtime | Low | Use managed certs, staged DNS cutovers, uptime checks |
| Secret leakage | Severe | Low | Secret Manager, least privilege, rotate keys |

---

## 13) Reference Snippets

### 13.1 Firebase Hosting multi‑target
```json
{
  "targets": { "hosting": { "av-web": ["av-web"], "av-ryde": ["av-rydesync"] } },
  "hosting": [
    { "target": "av-web", "public": "web", "rewrites": [
      { "source": "/api/rydesync/**", "run": { "serviceId": "rydesync-api", "region": "us-central1" } },
      { "source": "**", "destination": "/index.html" }
    ]},
    { "target": "av-ryde", "public": "ryde-web", "rewrites": [
      { "source": "**", "destination": "/index.html" }
    ]}
  ]
}
```

### 13.2 Cloud Run IAM (deployers vs operators)
- **Deployer role:** `roles/run.admin`, `roles/iam.serviceAccountUser` (on the runtime SA).
- **Operator role:** `roles/run.invoker`, `roles/logging.viewer`, `roles/monitoring.viewer`.

### 13.3 Redis Pub/Sub (Node example)
```js
import { createClient } from 'redis';
const pub = createClient({ url: process.env.REDIS_URL });
const sub = createClient({ url: process.env.REDIS_URL });
await pub.connect();
await sub.connect();

await sub.subscribe(`room:${roomId}`, (msg) => broadcastToRoom(roomId, msg));
await pub.publish(`room:${roomId}`, JSON.stringify({ type: 'SYNC', t: Date.now(), payload }));
```

---

## 14) SOPs (Ops Runbook)

- **Deploy:** PR → CI build → staging → smoke tests → prod.
- **Rollback:** keep last 3 Run revisions; `gcloud run services update-traffic` to rollback.
- **Secrets rotation:** quarterly; immediate on incident.
- **Access reviews:** monthly IAM review; disable dormant svc accts.
- **Backups:** export Firestore/RTDB nightly; GCS lifecycle rules for storage tiers.

---

## 15) Timeline (aggressive, 4 weeks)

| Week | Milestones |
|---|---|
| 1 | Create shared projects, budgets, DNS plans; central Auth; `av‑rydesync` online (Run + Redis) |
| 2 | Proxy or link integration from `av‑web`; move RydeSync to Redis sync; RTDB hardened |
| 3 | Stand up division projects (EchoVerse, Summit, etc.); cut subdomains; observability |
| 4 | Security hardening (CSP, Armor), cost dashboards, playbooks; UAT + cutover |

---

## 16) Decision Guide
- **Fastest:** link‑out to `ryde.aerovista.us` (separate project) with CORS.
- **Most seamless:** central Auth + reverse proxy under `aerovista.us`.
- **Best scale/cost:** WebSocket + Redis; Firebase for metadata only.

---

## 17) Next Actions (byte‑sharp)
1) Approve project/folder layout + billing account strategy.
2) Confirm Auth centralization (`av‑auth`) and domains list.
3) Choose routing style: **link‑out** vs **reverse‑proxy** for RydeSync.
4) Green‑light Redis plan (tier/region) and budget thresholds.
5) I’ll generate Terraform scaffolds for org/folders/projects, CI/CD templates, and baseline IAM.

