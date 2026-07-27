# Lieferspezifikation Säule C — Demand-Profile

**Adressat:** Sitzler
**Bezugsdokument:** `hrqde-shape-demand.ttl` · `shape-demand.puml`
**Version:** 0.1.1 · 2026-05-13

## 1. Auftrag

Aus Stellenausschreibungen extrahiert die NLP-Pipeline Demand-Profile:
welcher Arbeitgeber sucht für welche Position welche qualifizierten
Kandidaten, mit welchen Anforderungen, in welcher Ausprägung.

## 2. Was geliefert wird

Pro Stellenanzeige eine zusammenhängende Knotengruppe:

- **Ein `JobPosting`-Knoten** mit UUID, Posting-Datum, optional
  Quell-URL
- **Ein `Employer`-Knoten** mit Name
- Optional: **Ein `Occupation`-Verweis** auf eine ESCO-Berufs-URI
  (z.B. Datenwissenschaftler)
- **Mehrere `QualificationRequirement`-Knoten** im JobPosting

Jede QualificationRequirement trägt:

- **Genau eine ESCO-Skill-URI** (Option A)
- **Genau einen geforderten ProficiencyLevel** (DQR1–DQR8)
- **`requirementKind`** — entweder `must` oder `nice_to_have`
- **`provenanceConfidence`** als Dezimal in [0.0, 1.0]
- Optional: **`provenanceSource`** (job_posting / company_profile)

Strukturelle Form siehe `shape-demand.png`.

## 3. Option A — eine ESCO-URI pro Anforderung

Pro QualificationRequirement **genau ein** ESCO-Skill. Bei mehrdeutigen
Formulierungen entscheidet die Pipeline; die Restunsicherheit wird im
`provenanceConfidence`-Feld konserviert.

Die URI muss aus dem **offiziellen ESCO-Datensatz v1.2.1** stammen und
die kanonische UUID-Form haben
(`http://data.europa.eu/esco/skill/<uuid>`). Bezugsquelle und Details
stehen im README, Abschnitt "ESCO vocabulary". Eigene Platzhalter- oder
Bootstrap-URIs bestehen die Validierung ab Shapes v0.2.0 nicht mehr.

## 4. requirementKind — nur zwei Werte

Stellenanzeigen verwenden vielfältige Formulierungen für die Härte
einer Anforderung ("essential", "preferred", "would be a plus",
"mandatory"). Konsequente Reduktion auf zwei Werte:

- **`must`** — Anforderung erforderlich (essential, mandatory, required,
  Voraussetzung, zwingend, ...)
- **`nice_to_have`** — Anforderung erwünscht (preferred, would be a
  plus, von Vorteil, wünschenswert, ...)

Die Werte folgen einer Underscore-Schreibweise statt Bindestrich, um
Konflikte mit dem Subtraktions-Operator in automatisch generierten
Validierungs-Queries der neosemantics-SHACL-Engine zu vermeiden.

Die Reduktions-Heuristik ist Teil der Pipeline und gehört in deren
Dokumentation.

## 5. Default-ProficiencyLevel

Stellenanzeigen nennen oft keinen expliziten DQR-Level. In der Pipeline
ist ein begründeter Default zu setzen (z.B. DQR6 für Software-Berufe
wenn nicht anders spezifiziert) und die Default-Strategie im Begleit-
Protokoll zu dokumentieren.

## 6. Posting-ID (Strategie D1)

JobPosting-IDs sind UUIDs, die die Pipeline generiert. Die ursprüngliche
Quell-URL wird als `hrqde:sourceUrl` angehängt, um die Provenance zu
erhalten. So bleiben die IDs auch dann stabil, wenn Stellenbörsen ihre
URL-Strukturen ändern.

## 7. Anonymisierung des Arbeitgebers — offen

Die Frage, ob Employer-Namen real oder pseudonymisiert geliefert
werden, ist noch nicht entschieden (Klärung mit Lehrstuhl steht aus).
Bis dahin sind **echte Firmennamen** zu liefern; bei Bedarf kann später
eine Anonymisierungs-Pipeline nachgelagert werden. Die Shape ist
agnostisch — sie verlangt einen Namen, nicht aber dass er real ist.

## 8. Format und Konventionen

- **Serialisierungsformat:** Turtle (.ttl), UTF-8
- **Namespace:** beliebig (z.B. `http://hr-qde.org/data/sitzler/`)
- **Datei-Namen:** `sitzler-demand-v{version}.ttl`
- **Begleit-Protokoll:** Lieferdatum, Pipeline-Version, Anzahl
  Postings, abgedeckter Zeitraum, Quell-Plattformen, Default-Strategie,
  bekannte Limitationen

## 9. Lokale Validierung

```
docker compose up -d neo4j
docker cp ontology/shapes/hrqde-shapes-all.ttl hrqde-neo4j:/var/lib/neo4j/import/
docker cp sitzler-demand-v0.5.ttl hrqde-neo4j:/var/lib/neo4j/import/
docker compose exec neo4j cypher-shell -u neo4j -p <password>
```

In der cypher-shell:

```cypher
CALL n10s.validation.shacl.import.fetch(
  "file:///var/lib/neo4j/import/hrqde-shapes-all.ttl", "Turtle"
);
CALL n10s.rdf.import.fetch(
  "file:///var/lib/neo4j/import/sitzler-demand-v0.5.ttl", "Turtle"
);
CALL n10s.validation.shacl.validate();
```

Note: `hrqde-shapes-all.ttl` is the combined shape file. Individual
shape files (`hrqde-shape-demand.ttl` etc.) exist for modular reference
but cannot be loaded sequentially — the SHACL import procedure of
neosemantics overwrites previously loaded shape sets. Always use the
combined file in operational validation runs.

## 10. Inhaltliche Hinweise (nicht von SHACL geprüft)

- **Posting-Dubletten:** Wie behandelt die Pipeline identische
  Stellenanzeigen, die auf mehreren Plattformen erscheinen? Heuristik
  und Resultat im Begleit-Protokoll.
- **Mehrsprachigkeit:** Englischsprachige Stellenanzeigen in
  Deutschland — übersetzt die Pipeline für die ESCO-Zuordnung?
- **Anforderungs-Bündel:** Anzeigen formulieren oft "Java, Python oder
  C++". Drei einzelne QualificationRequirements als `nice_to_have`
  liefern, **nicht** eine kombinierte. Das passt zum Option-A-Anker
  des Gesamtmodells.

## 11. Anlaufstellen bei Fragen

- **Architekturentscheidungen, Schema-Änderungen, Erweiterungswünsche:**
  Abstimmung mit Adrian Vogler
- **Inhaltliche oder methodische Fragen zur Masterarbeit:** Abstimmung
  mit Adrian Vogler oder Prof. Dr. Hemmje
