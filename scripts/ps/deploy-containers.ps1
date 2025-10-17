param(
  [ValidateSet(
    'traefik','docker-socket-proxy','postgres','redis','authelia','landing',
    'n8n','filebrowser','portainer','aerocaller',
    'prometheus','grafana','uptime-kuma','dozzle','cadvisor',
    'ollama','openwebui',
    'foundation','observability','ai','all'
  )]
  [string]$Service='all'
)

$ErrorActionPreference = 'Stop'
$HostName = '100.115.9.61'  # Tailscale IP (use this for reliable connectivity)
$User = 'glyph'

function Invoke-SSH($cmd){
  ssh "${User}@${HostName}" $cmd
}

function Push-File($src,$dst){
  scp $src "${User}@${HostName}:$dst"
}

function Run-SSH($cmd){
  Invoke-SSH $cmd
}

function Deploy-Service($name, $composeFile, $setupCmd = $null) {
  Write-Host "==> Deploying $name..." -ForegroundColor Cyan
  
  if ($setupCmd) {
    Run-SSH $setupCmd
  }
  
  Push-File $composeFile "~/$(Split-Path $composeFile -Leaf)"
  Run-SSH "sudo install -m 0644 ~/$(Split-Path $composeFile -Leaf) /srv/core/$(Split-Path $composeFile -Leaf)"
  Run-SSH "sudo docker compose -f /srv/core/$(Split-Path $composeFile -Leaf) up -d"
  
  Write-Host "[OK] $name deployed" -ForegroundColor Green
}

# Create networks if needed
Write-Host "==> Ensuring Docker networks exist..." -ForegroundColor Yellow
Run-SSH 'sudo docker network ls | grep -q gateway || sudo docker network create gateway'
Run-SSH 'sudo docker network ls | grep -q backend || sudo docker network create backend'
Run-SSH 'sudo docker network ls | grep -q observability || sudo docker network create observability'

# Determine which services to deploy
$servicesToDeploy = @()

if ($Service -eq 'foundation') {
  Write-Host "`n" -NoNewline
  Write-Host "=== PHASE A: FOUNDATION ===" -ForegroundColor Magenta
  $servicesToDeploy = @('docker-socket-proxy','postgres','redis','authelia','landing')
}
elseif ($Service -eq 'observability') {
  Write-Host "`n" -NoNewline
  Write-Host "=== PHASE E: OBSERVABILITY ===" -ForegroundColor Magenta
  $servicesToDeploy = @('prometheus','grafana','uptime-kuma','dozzle','cadvisor')
}
elseif ($Service -eq 'ai') {
  Write-Host "`n" -NoNewline
  Write-Host "=== PHASE C: AI ===" -ForegroundColor Magenta
  $servicesToDeploy = @('ollama','openwebui')
}
elseif ($Service -eq 'all') {
  Write-Host "`n" -NoNewline
  Write-Host "=== DEPLOYING ALL SERVICES ===" -ForegroundColor Magenta
  $servicesToDeploy = @('traefik','docker-socket-proxy','postgres','redis','authelia','landing',
                         'prometheus','grafana','uptime-kuma','dozzle','cadvisor',
                         'ollama','openwebui','n8n','filebrowser','portainer','aerocaller')
}
else {
  $servicesToDeploy = @($Service)
}

# Deploy Traefik (if in list)
if ($servicesToDeploy -contains 'traefik'){
  Run-SSH "sudo mkdir -p /opt/nexus/traefik/dynamic /etc/ssl/tailscale"
  Run-SSH "sudo chown -R ${User}:${User} /opt/nexus/traefik"
  Push-File "docker/traefik-dynamic.yml" "~/traefik-dynamic.yml"
  Push-File "docker/tailscale-certs.yml" "~/tailscale-certs.yml"
  Push-File "docker/tailnet-routes.yml" "~/tailnet-routes.yml"
  Run-SSH "sudo install -m 0644 ~/traefik-dynamic.yml /opt/nexus/traefik/dynamic/traefik-dynamic.yml"
  Run-SSH "sudo install -m 0644 ~/tailscale-certs.yml /opt/nexus/traefik/dynamic/tailscale-certs.yml"
  Run-SSH "sudo install -m 0644 ~/tailnet-routes.yml /opt/nexus/traefik/dynamic/tailnet-routes.yml"
  Deploy-Service 'Traefik' 'docker/compose-traefik.yml'
}

# Deploy Docker Socket Proxy (if in list)
if ($servicesToDeploy -contains 'docker-socket-proxy'){
  Deploy-Service 'Docker Socket Proxy' 'docker/compose-docker-socket-proxy.yml'
}

# Deploy PostgreSQL (if in list)
if ($servicesToDeploy -contains 'postgres'){
  Run-SSH "sudo mkdir -p /srv/core/data/postgres /srv/core/config/postgres"
  Run-SSH "sudo chown -R ${User}:${User} /srv/core/data/postgres /srv/core/config/postgres"
  Deploy-Service 'PostgreSQL' 'docker/compose-postgres.yml'
  
  # Push init script
  Push-File 'configs/postgres/init-databases.sql' '~/init-databases.sql'
  Run-SSH "sudo install -m 0644 ~/init-databases.sql /srv/core/config/postgres/init-databases.sql"
}

# Deploy Redis (if in list)
if ($servicesToDeploy -contains 'redis'){
  Run-SSH "sudo mkdir -p /srv/core/data/redis"
  Run-SSH "sudo chown -R ${User}:${User} /srv/core/data/redis"
  Deploy-Service 'Redis' 'docker/compose-redis.yml'
}

# Deploy Authelia (if in list)
if ($servicesToDeploy -contains 'authelia'){
  Run-SSH "sudo mkdir -p /opt/nexus/authelia"
  Run-SSH "sudo chown -R ${User}:${User} /opt/nexus/authelia"
  Deploy-Service 'Authelia' 'docker/compose-authelia.yml'
  
  # Push config files
  Push-File 'configs/authelia/configuration.yml' '~/authelia-configuration.yml'
  Push-File 'configs/authelia/users_database.yml' '~/authelia-users.yml'
  Run-SSH "sudo install -m 0644 ~/authelia-configuration.yml /opt/nexus/authelia/configuration.yml"
  Run-SSH "sudo install -m 0644 ~/authelia-users.yml /opt/nexus/authelia/users_database.yml"
  
  Write-Host "[WARNING] IMPORTANT: Update /opt/nexus/authelia/users_database.yml with real password hash!" -ForegroundColor Yellow
}

# Deploy Landing Page (if in list)
if ($servicesToDeploy -contains 'landing'){
  Run-SSH "sudo mkdir -p /srv/core/landing /srv/core/config/landing"
  Run-SSH "sudo chown -R ${User}:${User} /srv/core/landing /srv/core/config/landing"
  Deploy-Service 'Landing Page' 'docker/compose-landing.yml'
  
  # Push landing page files
  Push-File 'aerovista-landing.html' '~/index.html'
  Push-File 'configs/landing/nginx.conf' '~/landing-nginx.conf'
  Run-SSH "sudo install -m 0644 ~/index.html /srv/core/landing/index.html"
  Run-SSH "sudo install -m 0644 ~/landing-nginx.conf /srv/core/config/landing/nginx.conf"
}

# Deploy Prometheus (if in list)
if ($servicesToDeploy -contains 'prometheus'){
  Run-SSH "sudo mkdir -p /srv/core/data/prometheus /srv/core/config/prometheus"
  Run-SSH "sudo chown -R ${User}:${User} /srv/core/data/prometheus /srv/core/config/prometheus"
  Deploy-Service 'Prometheus' 'docker/compose-prometheus.yml'
  
  # Push config
  Push-File 'configs/prometheus/prometheus.yml' '~/prometheus.yml'
  Run-SSH "sudo install -m 0644 ~/prometheus.yml /srv/core/config/prometheus/prometheus.yml"
}

# Deploy Grafana (if in list)
if ($servicesToDeploy -contains 'grafana'){
  Run-SSH "sudo mkdir -p /srv/core/data/grafana"
  Run-SSH "sudo chown -R 472:472 /srv/core/data/grafana"
  Deploy-Service 'Grafana' 'docker/compose-grafana.yml'
}

# Deploy Uptime Kuma (if in list)
if ($servicesToDeploy -contains 'uptime-kuma'){
  Run-SSH "sudo mkdir -p /srv/core/data/uptime-kuma"
  Run-SSH "sudo chown -R ${User}:${User} /srv/core/data/uptime-kuma"
  Deploy-Service 'Uptime Kuma' 'docker/compose-uptime-kuma.yml'
}

# Deploy Dozzle (if in list)
if ($servicesToDeploy -contains 'dozzle'){
  Deploy-Service 'Dozzle' 'docker/compose-dozzle.yml'
}

# Deploy cAdvisor (if in list)
if ($servicesToDeploy -contains 'cadvisor'){
  Deploy-Service 'cAdvisor' 'docker/compose-cadvisor.yml'
}

# Deploy Ollama (if in list)
if ($servicesToDeploy -contains 'ollama'){
  Run-SSH "sudo mkdir -p /srv/core/data/ollama"
  Run-SSH "sudo chown -R ${User}:${User} /srv/core/data/ollama"
  Deploy-Service 'Ollama' 'docker/compose-ollama.yml'
  
  Write-Host "==> Pulling AI models (this may take 5-10 minutes)..." -ForegroundColor Yellow
  Run-SSH "sudo docker exec ollama ollama pull llama3.2"
  Write-Host "[OK] llama3.2 model ready" -ForegroundColor Green
}

# Deploy Open WebUI (if in list)
if ($servicesToDeploy -contains 'openwebui'){
  Run-SSH "sudo mkdir -p /srv/core/data/openwebui"
  Run-SSH "sudo chown -R ${User}:${User} /srv/core/data/openwebui"
  Deploy-Service 'Open WebUI' 'docker/compose-openwebui.yml'
}

# Deploy Portainer (if in list)
if ($servicesToDeploy -contains 'portainer'){
  Run-SSH 'sudo docker stop portainer 2>/dev/null || true'
  Run-SSH 'sudo docker rm portainer 2>/dev/null || true'
  Deploy-Service 'Portainer' 'docker/compose-portainer.yml'
  Write-Host "[WARNING] IMPORTANT: Open https://portainer.nxcore.tail79107c.ts.net/ within 5 minutes to create admin!" -ForegroundColor Yellow
}

# Deploy n8n (if in list)
if ($servicesToDeploy -contains 'n8n'){
  Deploy-Service 'n8n' 'docker/compose-n8n.yml'
}

# Deploy FileBrowser (if in list)
if ($servicesToDeploy -contains 'filebrowser'){
  Deploy-Service 'FileBrowser' 'docker/compose-filebrowser.yml'
}

# Deploy AeroCaller (if in list)
if ($servicesToDeploy -contains 'aerocaller'){
  Run-SSH "sudo mkdir -p /opt/nexus/aerocaller"
  Run-SSH "sudo chown -R ${User}:${User} /opt/nexus/aerocaller"
  scp -r "apps/AeroCaller/*" "${User}@${HostName}:/opt/nexus/aerocaller/"
  Deploy-Service 'AeroCaller' 'docker/compose-aerocaller.yml'
}

Write-Host "`n[OK] Deployment complete!" -ForegroundColor Green
Write-Host "==> Check status: sudo docker ps" -ForegroundColor Cyan
