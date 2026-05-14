# =====================================================================
# HR-QDE Masterand Toolkit — Bootstrap Script (Windows / PowerShell)
# =====================================================================
#
# Runs after the Neo4j container is healthy. Copies the ontology, the
# combined SHACL shapes, and init.cypher into the container, then runs
# init.cypher to configure the graph.
#
# Idempotent: re-running on an already-configured container produces
# warnings but no harm.
#
# Usage:  .\bootstrap.ps1
# =====================================================================

$ErrorActionPreference = "Stop"

$Container = "hr-qde-masterand-neo4j"
$ImportPath = "/var/lib/neo4j/import"

Write-Host ""
Write-Host "==> HR-QDE Masterand Toolkit Bootstrap" -ForegroundColor Cyan
Write-Host ""

# --- Pre-flight check -----------------------------------------------

Write-Host "[1/4] Verifying container is running..." -ForegroundColor Yellow
$status = docker compose ps --format json | ConvertFrom-Json
if (-not $status) {
    Write-Host "  [FAIL] Container '$Container' is not running." -ForegroundColor Red
    Write-Host "        Run 'docker compose up -d' first, wait for healthy status." -ForegroundColor Red
    exit 1
}
Write-Host "  [OK] Container is running."

# --- Copy files into the container ----------------------------------

Write-Host "[2/4] Copying files into container..." -ForegroundColor Yellow

$files = @(
    "ontology/hrqde-ontology-v0.1.ttl",
    "ontology/hrqde-shapes-all.ttl",
    "init.cypher"
)

foreach ($file in $files) {
    if (-not (Test-Path $file)) {
        Write-Host "  [FAIL] Missing file: $file" -ForegroundColor Red
        exit 1
    }
    Write-Host "  copying $file ..."
    docker cp $file "${Container}:${ImportPath}/"
}

Write-Host "  [OK] All files copied."

# --- Run init.cypher inside the container ---------------------------

Write-Host "[3/4] Running init.cypher inside container..." -ForegroundColor Yellow
Write-Host "      (this configures the graph, loads the ontology, loads the shapes)"

docker compose exec -T neo4j cypher-shell `
    -u neo4j -p masterand-toolkit `
    --file "$ImportPath/init.cypher"

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "  [FAIL] init.cypher returned a non-zero exit code." -ForegroundColor Red
    Write-Host "        Inspect the output above. Common causes:"
    Write-Host "          - The graph is already configured (re-run is harmless, ignore warnings)."
    Write-Host "          - A shape or ontology file has syntax errors."
    exit $LASTEXITCODE
}

Write-Host "  [OK] init.cypher completed."

# --- Verification ---------------------------------------------------

Write-Host "[4/4] Verifying setup..." -ForegroundColor Yellow

$verify = @"
CALL n10s.validation.shacl.listShapes() YIELD target
RETURN count(DISTINCT target) AS targetCount;
"@

docker compose exec -T neo4j cypher-shell `
    -u neo4j -p masterand-toolkit `
    "$verify"

Write-Host ""
Write-Host "==> Bootstrap complete." -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:"
Write-Host "  - Open the Neo4j browser at http://localhost:7474"
Write-Host "  - Login: neo4j / masterand-toolkit"
Write-Host "  - Read your pillar's spec in specs/MASTERAND_<NAME>.md"
Write-Host "  - Inspect the conformant example in examples/"
Write-Host "  - Validate your first delivery as described in README.md"
Write-Host ""
