# AeroVista Multi-Node Architecture

**Vision:** Distribute services across multiple servers for performance, isolation, and scalability while maintaining simple, reliable communication via Tailscale mesh.

---

## Node Topology

### **Node A: NXCore (Core Services & Gateway)**
**Hardware:** Current server (192.168.7.209)  
**Role:** Primary gateway, reverse proxy, orchestration, observability  
**Tailscale Name:** `nxcore.tail79107c.ts.net`

**Services on Core:**
- ✅ Traefik (reverse proxy - entry point for all traffic)
- ✅ Kong/KrakenD (API gateway - orchestrates cross-node calls)
- ✅ Authelia (SSO/MFA - guards all user-facing services)
- ✅ n8n (workflow orchestration - talks to all nodes)
- ✅ Prometheus + Grafana (collects metrics from all nodes)
- ✅ Uptime Kuma (monitors all nodes)
- ✅ Portainer (manages containers on all nodes via agents)
- ✅ Landing Page (shows status of all services across all nodes)
- FileBrowser (access files across nodes)
- Dozzle (view logs from all nodes)
- Syncthing (sync files between nodes)
- Formbricks
- Mailpit

### **Node B: DataCore (Databases & Storage)**
**Hardware:** Dedicated DB server (high IOPS SSD)  
**Role:** Persistent data, object storage, search  
**Tailscale Name:** `datacore.tail79107c.ts.net`

**Services on DataCore:**
- PostgreSQL 16 (primary database)
- Redis (cache & queues)
- MinIO (S3-compatible object storage)
- Meilisearch (search engine)
- PostgREST (auto REST API from Postgres views - read-only)
- pg_prometheus (time-series extension for Postgres)
- Backup agents (Restic, rclone)
- node_exporter (metrics)
- promtail (logs → Core Loki)

### **Node C: AINode (LLM & ML Workloads)**
**Hardware:** Server with GPU (NVIDIA 16GB+ recommended)  
**Role:** AI inference, embeddings, RAG  
**Tailscale Name:** `ainode.tail79107c.ts.net`

**Services on AINode:**
- Ollama (LLM runtime - models: llama3.2, codellama, mistral)
- Open WebUI (AI chat interface - proxied via Core Traefik)
- Embedding service (optional - for RAG)
- Qdrant (optional - vector database for embeddings)
- LibreTranslate (optional - local translation)
- Whisper (optional - speech-to-text)
- node_exporter (metrics)
- promtail (logs → Core Loki)

### **Node D: WorkspaceNode (Browser Workspaces)**
**Hardware:** High CPU/RAM server  
**Role:** User workspaces, dev environments  
**Tailscale Name:** `workspace.tail79107c.ts.net`

**Services on WorkspaceNode:**
- KasmVNC (Web Desktop - multiple instances for users)
- code-server (VS Code in browser - per-user instances)
- JupyterHub (multi-user JupyterLab)
- OnlyOffice Document Server
- draw.io
- Excalidraw
- BytePad (Etherpad)
- Dev containers (Node, Python, Go environments)
- node_exporter (metrics)
- promtail (logs → Core Loki)

### **Node E: MediaNode (Media Streaming & Files)**
**Hardware:** Large storage (4TB+), moderate CPU  
**Role:** Media serving, file hosting  
**Tailscale Name:** `media.tail79107c.ts.net`

**Services on MediaNode:**
- Navidrome (music streaming)
- Jellyfin (video/music/photos)
- CopyParty (EchoVerse static site + file server)
- Snapcast server (multi-room audio)
- Photoprism (optional - photo management)
- Calibre-web (optional - ebook library)
- node_exporter (metrics)
- promtail (logs → Core Loki)

### **Node F: EdgeNode (Raspberry Pi Sentinel)**
**Hardware:** Raspberry Pi 4/5 (8GB RAM)  
**Role:** Network monitoring, lightweight services  
**Tailscale Name:** `sentinel.tail79107c.ts.net`

**Services on EdgeNode:**
- Tailscale (always-on mesh node)
- node_exporter (metrics)
- promtail (logs → Core Loki)
- blackbox_exporter (network probes)
- Pihole (optional - DNS filtering)
- nmap (scheduled network scans)
- Speedtest tracker (internet speed monitoring)

---

## Communication Patterns

### Pattern 1: Gateway-First (Recommended for User-Facing APIs)

**Flow:** User → Core Traefik → Kong → Service(s) on Node(s) → Response

```
┌──────────┐
│  User    │
│ Browser  │
└────┬─────┘
     │ HTTPS
     ▼
┌─────────────────────────────────────────┐
│  NXCore (Core Node)                     │
│  ┌──────────┐    ┌──────────┐          │
│  │ Traefik  │───→│ Authelia │ (SSO)    │
│  │  :443    │    └──────────┘          │
│  └────┬─────┘                           │
│       │                                 │
│  ┌────▼──────────┐                      │
│  │ Kong Gateway  │                      │
│  │ /api/*        │                      │
│  └────┬──────────┘                      │
│       │                                 │
└───────┼─────────────────────────────────┘
        │ Tailscale mesh
        │
    ┌───┴────┬─────────┬──────────┐
    │        │         │          │
    ▼        ▼         ▼          ▼
┌────────┐ ┌─────┐  ┌──────┐  ┌────────┐
│DataCore│ │AI   │  │Media │  │Workspace│
│        │ │Node │  │Node  │  │  Node   │
└────────┘ └─────┘  └──────┘  └─────────┘
```

**Example Route:** `/api/insights/summary`

Kong config:
```yaml
routes:
  - name: insights-summary
    paths:
      - /api/insights/summary
    methods:
      - GET
    service: insights-service
    plugins:
      - name: rate-limiting
        config:
          minute: 10
      - name: request-transformer
        config:
          add:
            headers:
              - X-Service-Auth: ${KONG_SERVICE_TOKEN}

services:
  - name: insights-service
    url: http://kong-internal:8001/chain
    
upstream_targets:
  # Kong makes these calls sequentially:
  # 1. Query DB via PostgREST
  - name: postgrest-query
    url: http://datacore.tail79107c.ts.net:3000/rpc/get_recent_activity
    
  # 2. Send context to AI
  - name: ollama-summarize
    url: http://ainode.tail79107c.ts.net:11434/api/generate
    
  # 3. Return summary
```

**Benefits:**
- Single entry point (https://api.nxcore.tail79107c.ts.net/insights/summary)
- Centralized auth, rate limiting, logging
- Client doesn't know about multiple nodes
- Easy to add caching, retries, circuit breakers

### Pattern 2: Orchestrate in n8n (Recommended for Internal Jobs)

**Flow:** Trigger → n8n (Core) → Calls services on multiple nodes → Result

```
┌────────────────────────────────────────┐
│  n8n Workflow (on NXCore)              │
│                                        │
│  ┌──────────────────────────────────┐ │
│  │ 1. Postgres Query                │ │
│  │    GET datacore:3000/recent_logs │ │
│  └──────────┬───────────────────────┘ │
│             │                          │
│  ┌──────────▼───────────────────────┐ │
│  │ 2. Transform Data (JS/Python)    │ │
│  │    - Limit to 100 rows           │ │
│  │    - Format as prompt            │ │
│  └──────────┬───────────────────────┘ │
│             │                          │
│  ┌──────────▼───────────────────────┐ │
│  │ 3. Call AI for Summary           │ │
│  │    POST ainode:11434/api/generate│ │
│  │    { prompt, model: "llama3.2" } │ │
│  └──────────┬───────────────────────┘ │
│             │                          │
│  ┌──────────▼───────────────────────┐ │
│  │ 4. Save to MinIO                 │ │
│  │    PUT datacore:9000/summaries/  │ │
│  └──────────────────────────────────┘ │
└────────────────────────────────────────┘
```

**n8n Node Configuration:**

1. **Postgres Node** (custom query)
   - Host: `datacore.tail79107c.ts.net`
   - Port: `5432`
   - Database: `aerovista`
   - Query: `SELECT * FROM activity_logs ORDER BY created_at DESC LIMIT 100`

2. **Code Node** (transform)
   ```javascript
   const logs = $input.all();
   const prompt = `Summarize these activity logs:\n${JSON.stringify(logs)}`;
   return { prompt };
   ```

3. **HTTP Request Node** (Ollama)
   - URL: `http://ainode.tail79107c.ts.net:11434/api/generate`
   - Method: POST
   - Body:
     ```json
     {
       "model": "llama3.2",
       "prompt": "{{$node["Code"].json["prompt"]}}",
       "stream": false
     }
     ```

4. **MinIO Node** (save result)
   - Endpoint: `http://datacore.tail79107c.ts.net:9000`
   - Bucket: `summaries`
   - Object: `summary-{{$now}}.json`

**Benefits:**
- Visual workflow (no code)
- Easy scheduling (daily, hourly, on webhook)
- Built-in retry logic
- Can be triggered from landing page button

### Pattern 3: RAG Pipeline (for Advanced AI Queries)

**Flow:** Docs/Data → Periodic ETL → Vector Store → Query Time Lookup → AI

```
┌─────────────────────────────────────────────────────┐
│  Periodic ETL Job (n8n - runs daily)                │
│                                                      │
│  1. Fetch new docs from:                            │
│     - Postgres (DataCore)                           │
│     - MinIO (DataCore)                              │
│     - File shares (MediaNode)                       │
│                                                      │
│  2. Create embeddings:                              │
│     POST ainode:11434/api/embeddings                │
│     { model: "nomic-embed-text", prompt: "..." }    │
│                                                      │
│  3. Store vectors:                                  │
│     PUT datacore:6333/collections/docs/points       │
│     (Qdrant on DataCore)                            │
│                                                      │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│  Query Time (User asks question)                    │
│                                                      │
│  1. User query → embedding:                         │
│     POST ainode:11434/api/embeddings                │
│                                                      │
│  2. Vector search:                                  │
│     POST datacore:6333/collections/docs/search      │
│     Returns top-5 relevant docs                     │
│                                                      │
│  3. Build context + prompt:                         │
│     context = retrieved_docs.join("\n")             │
│     prompt = f"Context:\n{context}\n\nQ: {query}"   │
│                                                      │
│  4. Generate answer:                                │
│     POST ainode:11434/api/generate                  │
│     { model: "llama3.2", prompt: prompt }           │
│                                                      │
│  5. Return to user via Open WebUI                   │
└─────────────────────────────────────────────────────┘
```

**Services Needed:**
- **DataCore:** Qdrant (vector DB) - `qdrant/qdrant:latest` on port 6333
- **AINode:** Ollama with embedding model (`nomic-embed-text`)
- **Core:** n8n workflow + Open WebUI with RAG enabled

---

## Networking Configuration

### Tailscale Setup (All Nodes)

**On each node:**
```bash
# Install Tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# Join tailnet
sudo tailscale up --accept-routes

# Set hostname
sudo tailscale set --hostname=<nodename>
# Examples: nxcore, datacore, ainode, workspace, media, sentinel
```

**Tailscale ACL (Access Control):**
```json
{
  "tagOwners": {
    "tag:core": ["autogroup:admin"],
    "tag:data": ["autogroup:admin"],
    "tag:ai": ["autogroup:admin"],
    "tag:workspace": ["autogroup:admin"],
    "tag:media": ["autogroup:admin"],
    "tag:edge": ["autogroup:admin"]
  },
  "acls": [
    // Core can reach everything
    {
      "action": "accept",
      "src": ["tag:core"],
      "dst": ["*:*"]
    },
    // AI can reach DataCore (fetch context)
    {
      "action": "accept",
      "src": ["tag:ai"],
      "dst": ["tag:data:5432", "tag:data:6379", "tag:data:9000"]
    },
    // Workspace can reach DataCore (save work)
    {
      "action": "accept",
      "src": ["tag:workspace"],
      "dst": ["tag:data:5432", "tag:data:9000"]
    },
    // Everyone can reach Core gateway
    {
      "action": "accept",
      "src": ["*"],
      "dst": ["tag:core:443", "tag:core:80"]
    },
    // All nodes can send metrics/logs to Core
    {
      "action": "accept",
      "src": ["tag:data", "tag:ai", "tag:workspace", "tag:media", "tag:edge"],
      "dst": ["tag:core:9090", "tag:core:3100"]
    }
  ]
}
```

**Apply tags:**
```bash
# On each node
sudo tailscale set --advertise-tags=tag:<nodetype>
# Examples:
# NXCore:     tag:core
# DataCore:   tag:data
# AINode:     tag:ai
# Workspace:  tag:workspace
# MediaNode:  tag:media
# EdgeNode:   tag:edge
```

### DNS Resolution

**Automatic via Tailscale MagicDNS:**
- `nxcore.tail79107c.ts.net` → NXCore
- `datacore.tail79107c.ts.net` → DataCore
- `ainode.tail79107c.ts.net` → AINode
- `workspace.tail79107c.ts.net` → WorkspaceNode
- `media.tail79107c.ts.net` → MediaNode
- `sentinel.tail79107c.ts.net` → EdgeNode

**Usage in compose files:**
```yaml
# On NXCore - Kong calls DataCore
environment:
  - POSTGRES_HOST=datacore.tail79107c.ts.net
  - OLLAMA_HOST=http://ainode.tail79107c.ts.net:11434
```

### Service Discovery

**Option 1: Static config (simple, recommended)**
- Hard-code Tailscale hostnames in configs
- Update if nodes change (rare)

**Option 2: Consul (advanced, optional)**
- Run Consul server on Core
- Agents on all nodes
- Services auto-register
- Kong/n8n query Consul for endpoints

---

## Security Model

### Inter-Service Authentication

**Method 1: Tailscale ACL Tags (Network-Level)**
- Tag-based firewall rules
- No app changes needed
- Least privilege by default

**Method 2: Service Tokens (Application-Level)**
- Kong generates short-lived JWT
- Services validate token
- Stored in Vault or env vars

**Example - Kong to PostgREST:**
```yaml
# Kong plugin
- name: jwt
  config:
    secret_is_base64: false
    run_on_preflight: true
    claims_to_verify:
      - exp
      - iss
    key_claim_name: iss
    
# PostgREST config
db-pre-request = "app.authenticate_service"
```

**Example - n8n to Ollama:**
```javascript
// n8n HTTP Request node
{
  "headers": {
    "Authorization": "Bearer {{$env.OLLAMA_SERVICE_TOKEN}}"
  }
}
```

### Database Security (PostgREST on DataCore)

**Create read-only role:**
```sql
-- On DataCore Postgres
CREATE ROLE web_anon NOLOGIN;
GRANT USAGE ON SCHEMA public TO web_anon;

-- Create safe views (no PII)
CREATE VIEW public.activity_summary AS
  SELECT 
    date_trunc('hour', created_at) as hour,
    event_type,
    count(*) as event_count
  FROM activity_logs
  GROUP BY 1, 2;

GRANT SELECT ON public.activity_summary TO web_anon;

-- Create RPC functions for complex queries
CREATE OR REPLACE FUNCTION public.get_recent_activity(hours int DEFAULT 24)
RETURNS TABLE(event_type text, count bigint) AS $$
  SELECT event_type, count(*)
  FROM activity_logs
  WHERE created_at > now() - interval '1 hour' * hours
  GROUP BY event_type
  ORDER BY count DESC;
$$ LANGUAGE SQL STABLE;

GRANT EXECUTE ON FUNCTION public.get_recent_activity TO web_anon;
```

**PostgREST config (`/opt/nexus/postgrest/postgrest.conf` on DataCore):**
```conf
db-uri = "postgres://web_anon@localhost:5432/aerovista"
db-schemas = "public"
db-anon-role = "web_anon"
server-host = "0.0.0.0"
server-port = 3000
jwt-secret = "<shared-secret-with-kong>"
```

**Docker compose (DataCore):**
```yaml
services:
  postgrest:
    image: postgrest/postgrest:latest
    container_name: postgrest
    networks:
      - backend
    ports:
      - "3000:3000"
    environment:
      - PGRST_DB_URI=postgres://web_anon@postgres:5432/aerovista
      - PGRST_DB_ANON_ROLE=web_anon
      - PGRST_JWT_SECRET=${POSTGREST_JWT_SECRET}
    restart: unless-stopped
```

**Access from Core:**
```bash
# From NXCore (Kong or n8n)
curl http://datacore.tail79107c.ts.net:3000/rpc/get_recent_activity?hours=48
# Returns JSON array

curl http://datacore.tail79107c.ts.net:3000/activity_summary?hour=gte.2025-10-01
# Returns filtered view data
```

---

## Deployment Strategy

### Phase 1: Single Node (Current - NXCore)
**Status:** In progress  
**Services:** All on NXCore as per CLEAN_INSTALL_GUIDE.md  
**Purpose:** Prove the stack works, establish patterns

### Phase 2: Split Data Layer (DataCore)
**Hardware:** Get/provision DataCore server  
**Deploy:**
1. Install Ubuntu Server + Tailscale
2. Join tailnet as `datacore.tail79107c.ts.net`
3. Deploy:
   - PostgreSQL 16
   - Redis
   - MinIO
   - Meilisearch
   - PostgREST
   - node_exporter
   - promtail

4. Migrate data:
   - Export from NXCore Postgres: `pg_dump`
   - Import to DataCore Postgres
   - Update NXCore services to point to `datacore.tail79107c.ts.net:5432`

**Time:** 2-3 hours  
**Benefit:** DB isolated, better backups, dedicated IOPS

### Phase 3: Add AI Node
**Hardware:** Server with GPU  
**Deploy:**
1. Install Ubuntu Server + NVIDIA drivers + Tailscale
2. Join tailnet as `ainode.tail79107c.ts.net`
3. Deploy:
   - Ollama (with GPU)
   - Qdrant (vector DB)
   - node_exporter
   - promtail

4. Pull models:
   ```bash
   docker exec ollama ollama pull llama3.2
   docker exec ollama ollama pull codellama
   docker exec ollama ollama pull nomic-embed-text
   ```

5. Update Open WebUI on NXCore to point to `ainode.tail79107c.ts.net:11434`

**Time:** 1-2 hours  
**Benefit:** GPU acceleration, offload AI from Core

### Phase 4: Add Workspace Node
**Hardware:** High CPU/RAM server  
**Deploy:**
1. Install Ubuntu Server + Tailscale
2. Join tailnet as `workspace.tail79107c.ts.net`
3. Deploy:
   - KasmVNC (web desktop)
   - code-server instances
   - JupyterHub
   - OnlyOffice
   - draw.io, Excalidraw, BytePad

4. Configure Traefik on NXCore to proxy workspace services

**Time:** 2-3 hours  
**Benefit:** User workspaces don't impact Core/DB/AI

### Phase 5: Add Media Node
**Hardware:** High storage server  
**Deploy:**
1. Install Ubuntu Server + Tailscale
2. Join tailnet as `media.tail79107c.ts.net`
3. Deploy:
   - Navidrome
   - Jellyfin
   - CopyParty
   - Snapcast

4. Mount `/srv/media` from NXCore or migrate media files

**Time:** 1-2 hours  
**Benefit:** Large media storage doesn't fill Core

### Phase 6: Add Edge Sentinel (Raspberry Pi)
**Hardware:** Raspberry Pi 4/5 (8GB)  
**Deploy:**
1. Install Raspberry Pi OS Lite + Tailscale
2. Join tailnet as `sentinel.tail79107c.ts.net`
3. Deploy:
   - node_exporter
   - promtail
   - blackbox_exporter
   - pihole (optional)
   - speedtest tracker

**Time:** 30 minutes  
**Benefit:** Network monitoring, always-on sentinel

---

## Monitoring Multi-Node Setup

### Prometheus Scrape Config (on NXCore)

```yaml
# /opt/nexus/prometheus/prometheus.yml
scrape_configs:
  # NXCore metrics
  - job_name: 'nxcore-node'
    static_configs:
      - targets: ['localhost:9100']  # node_exporter
        labels:
          node: 'nxcore'
          role: 'core'
          
  - job_name: 'nxcore-containers'
    static_configs:
      - targets: ['cadvisor:8080']
        labels:
          node: 'nxcore'
          
  # DataCore metrics
  - job_name: 'datacore-node'
    static_configs:
      - targets: ['datacore.tail79107c.ts.net:9100']
        labels:
          node: 'datacore'
          role: 'data'
          
  - job_name: 'datacore-postgres'
    static_configs:
      - targets: ['datacore.tail79107c.ts.net:9187']  # postgres_exporter
        labels:
          node: 'datacore'
          
  # AINode metrics
  - job_name: 'ainode-node'
    static_configs:
      - targets: ['ainode.tail79107c.ts.net:9100']
        labels:
          node: 'ainode'
          role: 'ai'
          
  # Workspace metrics
  - job_name: 'workspace-node'
    static_configs:
      - targets: ['workspace.tail79107c.ts.net:9100']
        labels:
          node: 'workspace'
          role: 'workspace'
          
  # Media metrics
  - job_name: 'media-node'
    static_configs:
      - targets: ['media.tail79107c.ts.net:9100']
        labels:
          node: 'media'
          role: 'media'
          
  # Edge sentinel
  - job_name: 'sentinel-node'
    static_configs:
      - targets: ['sentinel.tail79107c.ts.net:9100']
        labels:
          node: 'sentinel'
          role: 'edge'
```

### Grafana Dashboards

**Multi-Node Overview Dashboard:**
- CPU/RAM/Disk per node
- Service health per node
- Cross-node request latency
- DB → AI → Core request traces

**Service Mesh Dashboard:**
- Request flow visualization
- Error rates per route
- p99 latency per service
- Kong API gateway metrics

---

## Example: End-to-End Request Flow

**User Request:** "Show me a summary of today's activity"

```
1. Browser → https://nxcore.tail79107c.ts.net/api/insights/summary
   ↓
2. NXCore Traefik → Authelia (verify user)
   ↓
3. NXCore Traefik → Kong Gateway
   ↓
4. Kong → DataCore PostgREST
   GET http://datacore.tail79107c.ts.net:3000/rpc/get_recent_activity?hours=24
   Response: [{ event_type: "login", count: 15 }, ...]
   ↓
5. Kong → Transform data (internal function)
   Build prompt: "Summarize these events: ..."
   ↓
6. Kong → AINode Ollama
   POST http://ainode.tail79107c.ts.net:11434/api/generate
   Body: { model: "llama3.2", prompt: "...", stream: false }
   Response: { response: "Today saw 15 logins, 3 file uploads..." }
   ↓
7. Kong → Return to user (via Traefik)
   ↓
8. Browser displays summary
```

**Latency Breakdown:**
- Authelia auth: ~10ms
- Kong routing: ~5ms
- PostgREST query (DataCore): ~50ms
- Data transform: ~5ms
- Ollama inference (AINode): ~2000ms (GPU) / ~8000ms (CPU)
- Response assembly: ~10ms
- **Total:** ~2080ms (with GPU) or ~8080ms (CPU only)

**Logged in:**
- Prometheus (request count, latency histogram)
- Loki (full request logs from all nodes)
- Uptime Kuma (endpoint availability)
- Kong analytics (API usage per user)

---

## Failure Scenarios & Handling

### Scenario 1: DataCore Postgres is down
**Detection:** Prometheus `up{job="datacore-postgres"}` = 0  
**Alert:** Alertmanager → Slack/Email within 30s  
**Behavior:**
- PostgREST returns 503
- Kong circuit breaker trips after 3 failures
- User sees: "Database temporarily unavailable"
- n8n workflows queue for retry

**Mitigation:**
- Postgres primary/replica (on DataCore)
- Automated failover via Patroni
- Read queries go to replica

### Scenario 2: AINode is unreachable
**Detection:** Prometheus `up{job="ainode-node"}` = 0  
**Alert:** Alertmanager → Slack within 30s  
**Behavior:**
- Kong returns cached summary (if available)
- Or returns: "AI service unavailable, showing cached result"
- Open WebUI shows "Offline" status

**Mitigation:**
- Queue AI requests in Redis (on DataCore)
- Process when AINode returns
- Rate limit AI calls to prevent overload

### Scenario 3: Tailscale link degrades
**Detection:** Blackbox exporter (on EdgeNode) probes all nodes  
**Alert:** If latency > 100ms or packet loss > 5%  
**Behavior:**
- Services still work (TCP retries)
- Slow responses for cross-node calls

**Mitigation:**
- Tailscale automatically re-routes
- Direct LAN peering if possible
- Cache frequently-accessed data locally

### Scenario 4: NXCore (gateway) is down
**Detection:** External uptime check (Uptime Kuma public probe)  
**Alert:** Immediate page to admin  
**Behavior:**
- All user-facing services unavailable
- Internal node-to-node still works

**Mitigation:**
- Run Traefik + Kong on **two** core nodes (HA)
- Keepalived VIP for failover
- Or: Cloudflare Tunnel as backup ingress

---

## Performance Optimization

### Caching Strategy

**Layer 1: Browser (Service Worker)**
- Static assets (JS/CSS/images)
- API responses (with stale-while-revalidate)

**Layer 2: Traefik (HTTP Cache)**
- Public endpoints
- CDN-like behavior for media

**Layer 3: Redis (Application Cache - on DataCore)**
- Hot API responses (AI summaries, DB aggregates)
- Session data
- Rate limit counters

**Layer 4: Postgres (Materialized Views - on DataCore)**
- Pre-computed aggregations
- Refreshed hourly/daily

**Example - Kong cache plugin:**
```yaml
plugins:
  - name: proxy-cache
    config:
      strategy: redis
      redis:
        host: datacore.tail79107c.ts.net
        port: 6379
      content_type:
        - application/json
      cache_ttl: 300  # 5 minutes
      cache_control: true
```

### Connection Pooling

**PgBouncer on DataCore:**
```yaml
services:
  pgbouncer:
    image: pgbouncer/pgbouncer:latest
    container_name: pgbouncer
    networks:
      - backend
    ports:
      - "6432:6432"
    environment:
      - DATABASES_HOST=postgres
      - DATABASES_PORT=5432
      - DATABASES_DBNAME=aerovista
      - POOL_MODE=transaction
      - MAX_CLIENT_CONN=1000
      - DEFAULT_POOL_SIZE=25
```

**Usage:**
- Services connect to `datacore.tail79107c.ts.net:6432` (PgBouncer)
- Not `5432` (direct Postgres)
- Reduces connection overhead

---

## Cost & Resource Summary

### Hardware Investment

| Node | CPU | RAM | Storage | GPU | Est. Cost |
|------|-----|-----|---------|-----|-----------|
| NXCore (current) | 8c | 32GB | 500GB SSD | - | $0 (owned) |
| DataCore | 8c | 64GB | 2TB NVMe | - | $1200 |
| AINode | 12c | 64GB | 1TB SSD | RTX 4090 | $2500 |
| WorkspaceNode | 16c | 128GB | 1TB SSD | - | $1800 |
| MediaNode | 4c | 16GB | 8TB HDD | - | $800 |
| EdgeNode (RPi5) | 4c | 8GB | 256GB SD | - | $150 |
| **Total** | | | | | **$6450** |

### Operating Costs

- **Power:** ~$50/month (all nodes 24/7)
- **Tailscale:** $0 (personal use) or $5/user/month (team plan)
- **Backups (B2):** ~$10/month (500GB)
- **Total:** ~$60-100/month

### ROI vs SaaS

**Replaced services:**
- GitHub Codespaces: $0.18/hour → $0 (code-server)
- OpenAI API: $20/month/user → $0 (Ollama)
- Dropbox Business: $15/user/month → $0 (MinIO + Syncthing)
- Zapier/Make: $30/month → $0 (n8n)
- Office 365: $12/user/month → $0 (OnlyOffice)
- Datadog: $15/host/month → $0 (Prometheus + Grafana)

**For 5 users:**
- **SaaS cost:** ~$450/month
- **Self-hosted cost:** ~$80/month
- **Savings:** $370/month = **$4440/year**
- **Payback:** ~18 months

---

## Next Steps

**Immediate (Week 1):**
1. Complete clean install on NXCore (Phase A-E from CLEAN_INSTALL_GUIDE.md)
2. Set up Tailscale ACLs
3. Deploy PostgREST on NXCore (test pattern)
4. Create first n8n workflow (DB → AI → result)

**Short-term (Month 1):**
5. Provision DataCore server
6. Migrate Postgres + Redis + MinIO to DataCore
7. Update all services to use `datacore.tail79107c.ts.net`

**Medium-term (Month 2-3):**
8. Add AINode with GPU
9. Deploy Ollama + Open WebUI + RAG pipeline
10. Add WorkspaceNode for user environments

**Long-term (Month 4+):**
11. Add MediaNode for large media files
12. Add EdgeNode (Raspberry Pi) for monitoring
13. Implement HA for Core (two gateway nodes)

---

**Ready to start Phase A on NXCore?** Or would you like me to create the compose files for DataCore so you can start planning the hardware?

