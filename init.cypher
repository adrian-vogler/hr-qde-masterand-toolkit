// =====================================================================
// HR-QDE Masterand Toolkit — Neo4j Bootstrap
// Version 0.1  ·  2026-05-14
//
// Run this script once after the first container start to initialise
// the graph for HR-QDE delivery validation. It encodes the five
// neosemantics stumbling blocks documented in the upstream
// hr-qde-prototype repository, so masterands do not need to discover
// them independently.
//
// USAGE:
//   docker compose exec neo4j cypher-shell \
//       -u neo4j -p masterand-toolkit \
//       --file /var/lib/neo4j/import/init.cypher
// =====================================================================


// ---------------------------------------------------------------------
// Step 1: Graph configuration
//
// LESSON 1 (from hr-qde-prototype): handleVocabUris must be "SHORTEN"
// for SHACL validation to work. The default "IGNORE" breaks SHACL,
// and "MAP" produces UriNamespaceHasNoAssociatedPrefix errors.
// ---------------------------------------------------------------------

CALL n10s.graphconfig.init({
  handleVocabUris: "SHORTEN",
  handleMultival: "ARRAY",
  multivalPropList: [
    "http://www.w3.org/2000/01/rdf-schema#label",
    "http://www.w3.org/2000/01/rdf-schema#comment",
    "http://www.w3.org/2004/02/skos/core#prefLabel",
    "http://www.w3.org/2004/02/skos/core#altLabel"
  ],
  keepLangTag: true,
  handleRDFTypes: "LABELS",
  applyNeo4jNaming: false,
  keepCustomDataTypes: true
});


// ---------------------------------------------------------------------
// Step 2: Unique constraint on Resource.uri
//
// Required by neosemantics for consistent RDF import semantics.
// ---------------------------------------------------------------------

CREATE CONSTRAINT n10s_unique_uri IF NOT EXISTS
  FOR (r:Resource) REQUIRE r.uri IS UNIQUE;


// ---------------------------------------------------------------------
// Step 3: Namespace prefix registration
//
// LESSON 2 (from hr-qde-prototype): SHACL import requires namespace
// prefixes to be pre-registered. Auto-registration on rdf.import only
// applies to rdf.import.fetch, not to shacl.import.fetch.
// ---------------------------------------------------------------------

CALL n10s.nsprefixes.add("hrqde", "http://hr-qde.org/ontology/");
CALL n10s.nsprefixes.add("hrqde-shape", "http://hr-qde.org/shapes/");
CALL n10s.nsprefixes.add("voeltz", "http://hr-qde.org/data/voeltz/");
CALL n10s.nsprefixes.add("koeppe", "http://hr-qde.org/data/koeppe/");
CALL n10s.nsprefixes.add("sitzler", "http://hr-qde.org/data/sitzler/");
CALL n10s.nsprefixes.add("hei", "http://hr-qde.org/data/koeppe/hei/");
CALL n10s.nsprefixes.add("employer", "http://hr-qde.org/data/sitzler/employer/");
CALL n10s.nsprefixes.add("esco-skill", "http://data.europa.eu/esco/skill/");
CALL n10s.nsprefixes.add("esco-occupation", "http://data.europa.eu/esco/occupation/");
CALL n10s.nsprefixes.add("sh", "http://www.w3.org/ns/shacl#");
CALL n10s.nsprefixes.add("dcterms", "http://purl.org/dc/terms/");


// ---------------------------------------------------------------------
// Step 4: Load the HR-QDE skeleton ontology
//
// The skeleton defines all HR-QDE classes (Learner, EducationalModule,
// JobPosting, etc.) and properties (hasProfile, targetsCompetence,
// etc.). It is the schema against which masterand deliveries are
// validated.
// ---------------------------------------------------------------------

CALL n10s.rdf.import.fetch(
  "file:///var/lib/neo4j/import/hrqde-ontology-v0.1.ttl",
  "Turtle"
);


// ---------------------------------------------------------------------
// Step 5: Load the combined SHACL shape file
//
// LESSON 3 (from hr-qde-prototype): n10s.validation.shacl.import.fetch
// OVERWRITES previously loaded shape sets rather than accumulating.
// Therefore all shapes are aggregated into one file
// (hrqde-shapes-all.ttl) and loaded in a single call. Loading
// individual shape files sequentially leaves only the last one
// effective.
//
// LESSON 4 (from hr-qde-prototype): controlled-vocabulary values in
// sh:in use underscore form ("nice_to_have"), not hyphen. The
// neosemantics Cypher generator parses hyphens as subtraction
// operators in sh:in clauses.
//
// LESSON 5 (from hr-qde-prototype): sh:message texts contain no
// single quotes. The Cypher generator does not escape single quotes
// in message strings, causing query termination errors.
// ---------------------------------------------------------------------

CALL n10s.validation.shacl.import.fetch(
  "file:///var/lib/neo4j/import/hrqde-shapes-all.ttl",
  "Turtle"
);


// ---------------------------------------------------------------------
// Done.
//
// Verify the setup by running:
//   CALL n10s.graphconfig.show();           // shows SHORTEN config
//   CALL n10s.nsprefixes.list();            // shows 11+ registered prefixes
//   CALL n10s.validation.shacl.listShapes() YIELD target
//     RETURN DISTINCT target;               // shows 9 target classes
//
// To validate a delivery, see README.md "Validation workflow".
// ---------------------------------------------------------------------
