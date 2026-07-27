# HR-QDE Masterand Toolkit

Toolkit for contributing structured deliveries to the HR-QDE research
project at FernUniversität in Hagen. Provides the validation
contracts, a pre-configured Neo4j environment, and worked examples
for the three instance-level pillars.

## What this toolkit is for

The HR-QDE research project integrates three data streams about
human-resource qualification:

- **Säule A — As-Is profiles** of learners (extracted from applicant
  documents)
- **Säule B — Supply profiles** of educational modules (extracted
  from module handbooks of accredited higher-education institutions)
- **Säule C — Demand profiles** from job postings

Each pillar has its own NLP pipeline, developed in a master's thesis.
This toolkit lets a masterand validate the output of their pipeline
against the formal delivery contract **before** sending it to the
HR-QDE platform, so that integration failures are caught early.

(Säule D — the integrated domain ontology delivered by a fourth
masterand — is covered by a separate contract, not by this toolkit.)

## What is inside

| Directory | Contents |
|---|---|
| `ontology/` | The HR-QDE skeleton ontology (`hrqde-ontology-v0.1.ttl`) and the combined SHACL shape file (`hrqde-shapes-all.ttl`) |
| `specs/` | One Markdown spec per pillar describing the delivery format, with content-level guidance not encoded in SHACL |
| `diagrams/` | PlantUML sources (`.puml`) and rendered PNGs of the three pillar schemas |
| `examples/` | One conformant and one deliberately faulty example delivery per pillar |
| `neo4j-import/` | Files staged here are visible inside the Neo4j container as `/var/lib/neo4j/import/` |
| `compose.yaml` | Docker compose file with a stripped-down Neo4j+neosemantics setup |
| `init.cypher` | One-time bootstrap script that initialises the graph |
| `validate.py` | Authoritative pyshacl validation of a delivery against the combined shapes (see Validation workflow) |

## Prerequisites

- Docker Desktop installed and running
- Approximately 4 GB of free RAM for the Neo4j container
- Git for cloning the repo
- A text editor or IDE for inspecting TTL files

The masterand's own NLP pipeline is developed separately. This
toolkit does not constrain pipeline implementation language or
framework.

## Quick start

### 1. Clone the toolkit

```
git clone https://github.com/adrian-vogler/hr-qde-masterand-toolkit.git
cd hr-qde-masterand-toolkit
```

### 2. Start the Neo4j container

```
docker compose up -d
```

The container will be `healthy` after about 30–60 seconds. Confirm
with `docker compose ps`.

### 3. Run the bootstrap script

The script copies the relevant TTL files into the container, then
runs `init.cypher` to configure the graph, register namespace
prefixes, load the HR-QDE ontology, and load the SHACL shapes.

On Windows (PowerShell):

```
.\bootstrap.ps1
```

On Linux/macOS:

```
./bootstrap.sh
```

The script reports each step. On success, the graph is ready to
validate deliveries. The total runtime is under one minute.

### 4. Open the Neo4j browser

Browser: http://localhost:7474
Login: `neo4j` / `masterand-toolkit`

### 5. Verify the setup

In the Neo4j browser, run:

```cypher
CALL n10s.validation.shacl.listShapes() YIELD target
RETURN DISTINCT target;
```

Expected output: nine target classes (Learner, CompetencyProfile,
AcquiredCompetence, EducationalModule, LearningOutcome,
HigherEducationInstitution, JobPosting, QualificationRequirement,
Employer).

## Validation workflow

Once the toolkit is running, validating a delivery is a three-step
process. The example below uses a Säule A (Voeltz) delivery file
named `my-delivery.ttl`.

### Step 1: Copy the delivery into the container

```
docker cp my-delivery.ttl hr-qde-masterand-neo4j:/var/lib/neo4j/import/
```

### Step 2: Open the cypher shell

```
docker compose exec neo4j cypher-shell -u neo4j -p masterand-toolkit
```

### Step 3: Import and validate

```cypher
CALL n10s.rdf.import.fetch(
  "file:///var/lib/neo4j/import/my-delivery.ttl", "Turtle"
);

CALL n10s.validation.shacl.validate();
```

A conformant delivery returns no rows. A faulty delivery returns one
row per violation, with a focus node, the violated constraint, and a
human-readable message.

### Authoritative check: validate.py (pyshacl)

The neosemantics validator does not evaluate `sh:pattern` constraints
on IRI values. Among other things it therefore does not catch
non-canonical ESCO skill URIs (see the ESCO vocabulary section). The
authoritative validation therefore runs outside the container, with
pyshacl:

```
pip install pyshacl
python validate.py my-delivery.ttl
```

Exit code 0 means the delivery conforms; violations are printed with
focus node, constraint, and message. Run `validate.py` on every
delivery before sending it, in addition to (or instead of) the
in-container workflow above. The in-container workflow remains useful
for exploring your delivery as a graph.

To clean the delivery from the graph and validate a new one:

```cypher
MATCH (n:Resource)
WHERE n.uri STARTS WITH "http://hr-qde.org/data/voeltz/"
DETACH DELETE n;
```

(Adapt the URI prefix to your pillar.)

## How to learn from the examples

The `examples/` directory contains two files per pillar:

- `*-example-v0.1.ttl` — a conformant delivery, validates cleanly
- `*-example-faulty.ttl` — a faulty delivery with four deliberate
  violations, comments in the file identify each violation

To see the validator in action:

1. Bootstrap the toolkit (above)
2. Copy the faulty example into the container
3. Import it
4. Run `n10s.validation.shacl.validate()` and observe the four
   violations reported

Then repeat with the conformant example, observe no violations, and
use it as the structural template for your own pipeline output.

## Documentation roadmap

1. **Start with your pillar's spec** in `specs/MASTERAND_<NAME>.md`.
   It describes the delivery contract in prose, including
   content-level guidance not encoded in SHACL.
2. **Look at the schema diagram** in `diagrams/shape-<pillar>.png`
   for a visual sense of the data model.
3. **Inspect the conformant example** in `examples/` to see the
   format concretely.
4. **Inspect the faulty example** to see what the validator catches.
5. **Reference the SHACL shape** in `ontology/hrqde-shapes-all.ttl`
   for the formal contract.

## ESCO vocabulary (mandatory for all pillars)

All skill references in deliveries (`acquiredCompetenceOf`,
`requiresCompetence`, `targetsCompetence`, `refersToCompetence`) must
use **canonical URIs from the official ESCO dataset, version
v1.2.1** — the same version loaded in the HR-QDE platform graph.
Canonical skill URIs have the UUID form:

```
http://data.europa.eu/esco/skill/ccd0a1d9-afda-43d9-b901-96344886e14d
```

Self-invented or bootstrap URIs (for example
`http://data.europa.eu/esco/skill/mini/...`) do not exist in ESCO.
They import without error, but they never join with the other pillars
in the HR-QDE graph, so coverage and gap analysis stay empty. **Since
shapes v0.2.0 such URIs fail validation** instead of passing
silently.

### Where to get ESCO v1.2.1

Open <https://esco.ec.europa.eu/en/use-esco/download> in a browser.
In the **"Your ESCO dataset"** section, set:

- **Version:** `ESCO dataset - v1.2.1`
- **Content:** `Classification`
- **File type:** `ttl` (or `csv`, if your pipeline builds its concept
  index from tabular data; both carry the same canonical URIs)

Click **"Add to your package"**, then **"Export your dataset"**. The
download is a ZIP of about 173 MB; the TTL extracts to roughly
795 MB. Note: the default Windows extractor reports an "invalid ZIP"
error on this file, which is a known ESCO issue. Use 7-Zip
(<https://www.7-zip.org/>) or another modern extractor.

Use the extracted dataset as the source of your pipeline's concept
index, so that every mapped skill resolves to a canonical URI. As a
sanity check: ESCO v1.2.1 contains 15163 skills and 3047 occupations.

## Naming conventions for deliveries

Deliveries should be named:

```
{pillar}-{type}-v{version}.ttl
```

Examples:

- `voeltz-asis-v0.3.ttl`
- `koeppe-supply-v0.2.ttl`
- `sitzler-demand-v0.5.ttl`

Each delivery should include a brief Markdown protocol (e.g.,
`README-v0.3.md`) noting the delivery date, the pipeline version,
the number of records, and any known limitations.

## Stopping the toolkit

End-of-day:

```
docker compose stop
```

To restart the next day, simply `docker compose up -d`. Data and
configuration are preserved.

## When you need to start over

If the graph state becomes inconsistent or you want to test the
bootstrap from scratch:

```
docker compose down -v
docker compose up -d
```

Then re-run the bootstrap script. The `-v` flag destroys the volume,
so reimport is required.

## Limitations of v0.1

- Säule D (integrated domain ontology) is not yet covered; that
  contract follows in a later version.
- The in-container validator (neosemantics) catches `sh:pattern`
  violations only on string literals, not on IRI values. This affects
  out-of-range DQR levels expressed as URIs and the canonical-UUID
  rule for ESCO skill URIs (shapes v0.2.0). Mitigation: run
  `validate.py` (pyshacl), which evaluates all constraints; it is the
  authoritative check.
- Shape files are intentionally provided only in their combined form
  (`hrqde-shapes-all.ttl`). Loading individual shape files
  sequentially does not work in neosemantics; the combined file is
  the operationally valid form.

For a full discussion of these and other lessons learned during
shape development, see the upstream documentation in
`hr-qde-prototype/docs/components/C04c_Example_Deliveries.md`.

## Where the toolkit comes from

This toolkit is built on top of the main HR-QDE research repository,
`adrian-vogler/hr-qde-prototype`. The artefacts in `ontology/`,
`specs/`, `diagrams/`, and `examples/` are mirrored from there with
version pinning; they are updated periodically as the shape design
evolves.

The toolkit itself is licensed under CC-BY-SA 4.0.

## Contact

For architecture questions, schema changes, or extension requests:
**Adrian Vogler**.

For methodological questions about the master's thesis itself:
**Adrian Vogler** or **Prof. Dr. Matthias Hemmje**, FernUniversität
in Hagen.
