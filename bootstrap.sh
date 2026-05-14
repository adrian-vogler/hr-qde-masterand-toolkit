#!/usr/bin/env bash
# =====================================================================
# HR-QDE Masterand Toolkit — Bootstrap Script (Linux / macOS)
# =====================================================================
#
# Runs after the Neo4j container is healthy. Copies the ontology, the
# combined SHACL shapes, and init.cypher into the container, then runs
# init.cypher to configure the graph.
#
# Idempotent: re-running on an already-configured container produces
# warnings but no harm.
#
# Usage:  ./bootstrap.sh
# =====================================================================

set -e

CONTAINER="hr-qde-masterand-neo4j"
IMPORT_PATH="/var/lib/neo4j/import"

echo ""
echo "==> HR-QDE Masterand Toolkit Bootstrap"
echo ""

# --- Pre-flight check ------------------------------------------------

echo "[1/4] Verifying container is running..."
if ! docker compose ps --format json | grep -q "$CONTAINER"; then
    echo "  [FAIL] Container '$CONTAINER' is not running."
    echo "        Run 'docker compose up -d' first, wait for healthy status."
    exit 1
fi
echo "  [OK] Container is running."

# --- Copy files into the container -----------------------------------

echo "[2/4] Copying files into container..."

FILES=(
    "ontology/hrqde-ontology-v0.1.ttl"
    "ontology/hrqde-shapes-all.ttl"
    "init.cypher"
)

for f in "${FILES[@]}"; do
    if [ ! -f "$f" ]; then
        echo "  [FAIL] Missing file: $f"
        exit 1
    fi
    echo "  copying $f ..."
    docker cp "$f" "${CONTAINER}:${IMPORT_PATH}/"
done

echo "  [OK] All files copied."

# --- Run init.cypher inside the container ----------------------------

echo "[3/4] Running init.cypher inside container..."
echo "      (this configures the graph, loads the ontology, loads the shapes)"

docker compose exec -T neo4j cypher-shell \
    -u neo4j -p masterand-toolkit \
    --file "$IMPORT_PATH/init.cypher"

# --- Verification ----------------------------------------------------

echo "[4/4] Verifying setup..."

docker compose exec -T neo4j cypher-shell \
    -u neo4j -p masterand-toolkit \
    "CALL n10s.validation.shacl.listShapes() YIELD target RETURN count(DISTINCT target) AS targetCount;"

echo ""
echo "==> Bootstrap complete."
echo ""
echo "Next steps:"
echo "  - Open the Neo4j browser at http://localhost:7474"
echo "  - Login: neo4j / masterand-toolkit"
echo "  - Read your pillar's spec in specs/MASTERAND_<NAME>.md"
echo "  - Inspect the conformant example in examples/"
echo "  - Validate your first delivery as described in README.md"
echo ""
