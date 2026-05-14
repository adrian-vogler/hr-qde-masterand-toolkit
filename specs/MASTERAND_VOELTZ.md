# Lieferspezifikation Säule A — As-Is-Profile

**Adressat:** Voeltz
**Bezugsdokument:** `hrqde-shape-asis.ttl` · `shape-asis.puml`
**Version:** 0.1 · 2026-05-11

## 1. Auftrag

Aus den Eingangs-Dokumenten (Lebensläufe, Zeugnisse, Anschreiben,
Referenzen) extrahiert die NLP-Pipeline pro Person ein As-Is-Profil:
welche Kompetenzen besitzt die Person aktuell, in welcher Ausprägung,
woher wissen wir das.

Eine Lieferung umfasst mehrere Personen (typisch 3 als
Pseudonyme für die Diss-Demo).

## 2. Was geliefert wird

Pro Person eine zusammenhängende Knotengruppe:

- **Ein `Learner`-Knoten** mit pseudonymisierter ID
- **Ein `CompetencyProfile`** (gehört dem Learner)
- **Mehrere `AcquiredCompetence`-Knoten** im Profil (eine pro
  erkannter Kompetenz)

Jede AcquiredCompetence trägt:

- **Genau eine ESCO-Skill-URI** (siehe Option A unten)
- **Genau einen ProficiencyLevel** (DQR1–DQR8 als URI)
- **`provenanceConfidence`** als Dezimal in [0.0, 1.0]
- Optional: **`provenanceSource`** (cv / transcript / certificate /
  reference / self_declaration)
- Optional: **`acquiredOn`** als xsd:date

Die strukturelle Form ist im PlantUML-Diagramm `shape-asis.png`
visualisiert.

## 3. Option A — eine ESCO-URI pro Kompetenz

Pro AcquiredCompetence wird auf **genau einen** ESCO-Skill verwiesen.
Bei mehrdeutiger Quellinformation (z.B. "Datenbanken" — könnte SQL
Server oder use databases sein) entscheidet die Pipeline. Die
verbleibende Unsicherheit wird im `provenanceConfidence`-Feld
konserviert:

- 0.95+ → klar erkannt, eindeutig
- 0.70 → wahrscheinlich, geringe Mehrdeutigkeit
- 0.50 → mehrdeutig, beste Schätzung
- unter 0.50 → besser nicht liefern oder als low-confidence markieren

Diese Strategie ist die architektonische Verankerung der Säulen A/B/C:
nur durch 1:1-Zuordnung ist späterer mechanischer Vergleich zwischen
Lernerprofilen, Modul-Outcomes und Job-Anforderungen möglich.

## 4. Format und Konventionen

- **Serialisierungsformat:** Turtle (.ttl), UTF-8
- **Namespace der Lieferung:** beliebig (z.B.
  `http://hr-qde.org/data/voeltz/`), aber konsistent innerhalb einer
  Lieferung
- **Datei-Namen:** `voeltz-asis-v{version}.ttl`
- **Begleit-Protokoll:** kurzes Markdown mit Lieferdatum, Pipeline-
  Version, Anzahl Records, bekannte Limitationen

## 5. Lokale Validierung

Vor jeder Lieferung erfolgt eine lokale Validierung gegen die Shape.
Setup:

```
docker compose up -d neo4j
# Shapes und gemeinsame Constraints in den Container kopieren
docker cp ontology/shapes/hrqde-shapes-common.ttl hrqde-neo4j:/var/lib/neo4j/import/
docker cp ontology/shapes/hrqde-shape-asis.ttl hrqde-neo4j:/var/lib/neo4j/import/
# Die Lieferung in den Container kopieren
docker cp voeltz-asis-v0.3.ttl hrqde-neo4j:/var/lib/neo4j/import/
docker compose exec neo4j cypher-shell -u neo4j -p <password>
```

In der cypher-shell:

```cypher
CALL n10s.validation.shacl.import.fetch(
  "file:///var/lib/neo4j/import/hrqde-shape-asis.ttl", "Turtle"
);
CALL n10s.rdf.import.fetch(
  "file:///var/lib/neo4j/import/voeltz-asis-v0.3.ttl", "Turtle"
);
CALL n10s.validation.shacl.validate();
```

Ein sauberer Durchlauf liefert keine Zeilen. Jede zurückgegebene Zeile
verweist auf einen Knoten und eine verletzte Constraint mit
human-lesbarer Meldung.

## 6. Inhaltliche Hinweise (nicht von SHACL geprüft)

Diese Punkte sind Teil der Forschungsleistung, nicht der SHACL-
Validierung:

- **Pseudonymisierung:** Lerner-IDs dürfen nicht auf reale Personen
  zurückführbar sein
- **Provenance-Aggregation:** Wenn mehrere Quelldokumente eine
  Kompetenz belegen, ist die Heuristik der Confidence-Aggregation im
  Pipeline-Protokoll zu dokumentieren
- **DQR-Schätzung:** Wie wird der ProficiencyLevel aus einer
  Lebenslauf-Erwähnung abgeleitet? Diese Heuristik gehört in die
  Pipeline-Beschreibung.

## 7. Anlaufstellen bei Fragen

- **Architekturentscheidungen, Schema-Änderungen, Erweiterungswünsche:**
  Abstimmung mit Adrian Vogler
- **Inhaltliche oder methodische Fragen zur Masterarbeit:** Abstimmung
  mit Adrian Vogler oder Prof. Dr. Hemmje
