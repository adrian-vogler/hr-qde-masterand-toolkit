# HR-QDE Toolkit — Changelog

## 2026-05-17 — Ontology v0.1.1 / Shapes v0.1.3

### Ontologie-Datei
`ontology/hrqde-ontology-v0.1.1.ttl` (ersetzt v0.1)

**Hinzugefügt — Cluster 3 (Supply-Side):**
- `hrqde:UnmappedLearningOutcome` — Klasse für nicht abbildbare Outcome-Kandidaten (bewusst nicht subClassOf LearningOutcome, um SHACL-Vererbung zu vermeiden)
- `hrqde:hasUnmappedOutcome` — ObjectProperty: EducationalModule → UnmappedLearningOutcome
- `hrqde:reviewReason` — DatatypeProperty (string) auf UnmappedLearningOutcome
- `hrqde:evidenceExcerpt` — DatatypeProperty (string) auf UnmappedLearningOutcome
- `hrqde:moduleType` — DatatypeProperty (string, kontrolliertes Vokabular) auf EducationalModule
- `hrqde:institutionType` — ObjectProperty auf HigherEducationInstitution (war in Shapes referenziert, fehlte in Ontologie)

**Hinzugefügt — Cluster 2 (Demand-Side):**
- `hrqde:sourceUrl` — DatatypeProperty (anyURI) auf JobPosting (war in Shapes referenziert, fehlte in Ontologie)

**Geändert:**
- `hrqde:provenanceSource` und `hrqde:provenanceConfidence` — `rdfs:domain` entfernt, da diese Properties Cluster-übergreifend von AcquiredCompetence, LearningOutcome und QualificationRequirement genutzt werden. Wert-Listen werden per Klasse via SHACL `sh:in` enforced.

**Metadaten:**
- `dcterms:modified` 2026-05-17 ergänzt
- `owl:versionInfo` von "0.1" auf "0.1.1"

### SHACL-Shapes-Datei
`ontology/hrqde-shapes-all.ttl` (ersetzt v0.1.2)

**Neu:**
- `hrqde-shape:UnmappedLearningOutcomeShape` — Pflicht: rdfs:label, reviewReason, evidenceExcerpt; Optional mit kontrolliertem Wertebereich: provenanceSource, provenanceConfidence

**Erweitert:**
- `hrqde-shape:EducationalModuleShape`:
  - neuer Property-Constraint auf `hrqde:moduleType` mit `sh:in` (sechs zulässige Werte: Pflichtmodul, Bachelorseminar, Masterseminar, Fachpraktikum, Projektpraktikum, Abschlussmodul)
  - neuer Property-Constraint auf `hrqde:hasUnmappedOutcome` (optional, IRI-typed)

**Versions-Header:** v0.1.2 → v0.1.3 mit Begründung im File-Header.

### Hintergrund

Die Erweiterung schließt zwei Lücken:

1. **Säule-B-Pipeline-Erweiterungen v0.3.1 / v0.4 (Manus AI):** Der Lieferant hat als Reaktion auf methodische Anforderungen (saubere Trennung mapped vs. unmapped Outcomes, controlled vocabulary für moduleType) die genannten Konstrukte in seinen Lieferungen eingeführt. Sie waren bisher nur implizit in den Lieferungs-TTLs vorhanden, ohne formale Ontologie-Definition.

2. **Inkonsistenz Shapes vs. Ontologie:** Die Shapes-Datei v0.1.2 referenzierte `hrqde:institutionType` und `hrqde:sourceUrl`, ohne dass diese Properties in der Ontologie deklariert waren. v0.1.1 / v0.1.3 schließt diese Inkonsistenz.

### Nächste Schritte

1. **HermiT-Validierung** der neuen Ontologie-Version in Protégé. Erwartung: keine neuen unsatisfiable classes, keine Cardinality-Konflikte.

2. **Liefer-Validierung:** Die `koeppe-supply-example-v0.1.ttl` und alle Köppe-Lieferungen v0.3.1 / v0.4 (universal-run, informatics-data-run, business-management-run, fuh-only-run) sollten gegen die neuen Shapes validiert werden. Falls bestehende Modul-Knoten kein `moduleType` tragen, bricht die SHACL-Validierung nicht (sh:maxCount 1, kein sh:minCount).

3. **Beispieldatei aktualisieren:** `examples/koeppe-supply-example-v0.1.ttl` sollte mindestens ein Modul mit moduleType und mindestens ein hasUnmappedOutcome-Eintrag mit zugehörigem UnmappedLearningOutcome-Knoten enthalten. Demonstriert die neuen Konstrukte als Beispiel für künftige Lieferanten.

4. **Toolkit-Tag:** Nach Validierung Repository taggen mit `toolkit-v0.1.1` oder Sammlung-Tag `toolkit-v0.2`. Bisherige Konvention war Minor-Tag pro Lieferungs-Welle.
