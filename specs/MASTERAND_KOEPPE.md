# Lieferspezifikation Säule B — Supply-Profile

**Adressat:** Köppe
**Bezugsdokument:** `hrqde-shape-supply.ttl` · `shape-supply.puml`
**Version:** 0.1 · 2026-05-11

## 1. Auftrag

Aus den Modulhandbüchern deutscher Hochschulen extrahiert die
NLP-Pipeline Supply-Profile: welches Modul wird angeboten, was lehrt
es, welche Voraussetzungen verlangt es, wie ist es eingestuft.

**Inhaltlicher Scope:** Module aus akkreditierten Bachelor- und
Masterstudiengängen deutscher Hochschulen (im HR-QDE-Projekt als
**grundständige Lehre** bezeichnet). Diese Definition erweitert die
formale KMK-Auslegung (die nur Bachelor abdeckt) bewusst, weil
Bachelor und Master gleichermaßen zur regulären akademischen
Hochschullehre gehören — im Unterschied zum unstrukturierten
Weiterbildungsmarkt.

Diese inhaltliche Beschränkung ist Teil dieser Spec, **nicht** der
SHACL-Validierung. Die Shape akzeptiert technisch jeden DQR-Level
und jede positive ECTS-Zahl.

## 2. Was geliefert wird

Pro Modul eine zusammenhängende Knotengruppe:

- **Ein `EducationalModule`-Knoten** mit Code, Titel, ECTS-Wert
- **Ein `HigherEducationInstitution`-Knoten** (Verweis darauf)
- **Mehrere `LearningOutcome`-Knoten** im Modul (eines pro Lernziel)
- Optional: **Prerequisite-Skill-Verweise** auf ESCO

Jedes LearningOutcome trägt:

- **Genau eine ESCO-Skill-URI** (Option A)
- **Genau einen Ziel-ProficiencyLevel** (DQR1–DQR8 als URI)
- **`provenanceConfidence`** als Dezimal in [0.0, 1.0]
- Optional: **`provenanceSource`** (module_handbook / course_catalog)

Strukturelle Form siehe `shape-supply.png`.

## 3. Option A — eine ESCO-URI pro LearningOutcome

Die URI muss aus dem **offiziellen ESCO-Datensatz v1.2.1** stammen und
die kanonische UUID-Form haben
(`http://data.europa.eu/esco/skill/<uuid>`). Bezugsquelle und Details
stehen im README, Abschnitt "ESCO vocabulary". Eigene Platzhalter- oder
Bootstrap-URIs bestehen die Validierung ab Shapes v0.2.0 nicht mehr.

Analog zu Säule A: pro LearningOutcome **genau ein** ESCO-Skill. Bei
mehrdeutigen Lernzielen (z.B. "Programmierung allgemein") wird der
**abstraktere** ESCO-Skill gewählt (höher in der broaderTransitive-
Hierarchie, also z.B. `computer programming` statt `Python`). Die
ESCO-Hierarchie wird vom HR-QDE-Gap-Analyzer ausgewertet, der dadurch
automatisch erkennt, dass ein Modul über `computer programming`
implizit auch Python abdeckt.

## 4. Format und Konventionen

- **Serialisierungsformat:** Turtle (.ttl), UTF-8
- **Namespace:** beliebig (z.B. `http://hr-qde.org/data/koeppe/`)
- **Datei-Namen:** `koeppe-supply-v{version}.ttl`
- **Begleit-Protokoll:** Lieferdatum, Pipeline-Version, Anzahl Module,
  Quell-Hochschulen, bekannte Limitationen

## 5. Lokale Validierung

```
docker compose up -d neo4j
docker cp ontology/shapes/hrqde-shapes-common.ttl hrqde-neo4j:/var/lib/neo4j/import/
docker cp ontology/shapes/hrqde-shape-supply.ttl hrqde-neo4j:/var/lib/neo4j/import/
docker cp koeppe-supply-v0.2.ttl hrqde-neo4j:/var/lib/neo4j/import/
docker compose exec neo4j cypher-shell -u neo4j -p <password>
```

In der cypher-shell:

```cypher
CALL n10s.validation.shacl.import.fetch(
  "file:///var/lib/neo4j/import/hrqde-shape-supply.ttl", "Turtle"
);
CALL n10s.rdf.import.fetch(
  "file:///var/lib/neo4j/import/koeppe-supply-v0.2.ttl", "Turtle"
);
CALL n10s.validation.shacl.validate();
```

## 6. Inhaltliche Hinweise (nicht von SHACL geprüft)

- **HEI-Identifikation:** Eine HEI-URI ist konsistent über alle Module
  derselben Hochschule zu verwenden. Vorschlag:
  `http://hr-qde.org/data/koeppe/hei/{kuerzel}`
- **Institutionstyp (`hrqde:institutionType`):** Optional. Bei Angabe
  ist eine URI aus einem kontrollierten Vokabular zu verwenden (TBD;
  bis dahin frei mit eigenem Namespace und Konsistenz-Hinweis im
  Begleit-Protokoll)
- **DQR-Schätzung:** Wie wird aus Modul-Beschreibung und Studiengangs-
  Stufe (Bachelor/Master) der Ziel-ProficiencyLevel abgeleitet?
  Heuristik in Pipeline-Doku dokumentieren
- **Prerequisites:** Werden nur die im Modulhandbuch explizit
  genannten geliefert oder auch implizite? Klärung im Begleit-Protokoll

## 7. Anlaufstellen bei Fragen

- **Architekturentscheidungen, Schema-Änderungen, Erweiterungswünsche:**
  Abstimmung mit Adrian Vogler
- **Inhaltliche oder methodische Fragen zur Masterarbeit:** Abstimmung
  mit Adrian Vogler oder Prof. Dr. Hemmje
