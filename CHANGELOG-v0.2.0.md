# Toolkit v0.2.0 · 2026-07-27

## Shapes: ESCO-Vokabularbindung wird erzwungen

Alle vier Skill-URI-Constraints verlangen jetzt die kanonische UUID-Form
von ESCO-Skill-URIs:

- `hrqde:acquiredCompetenceOf` (Säule A, AcquiredCompetence)
- `hrqde:requiresCompetence` (Säule B, EducationalModule)
- `hrqde:targetsCompetence` (Säule B, LearningOutcome)
- `hrqde:refersToCompetence` (Säule C, QualificationRequirement)

Neues Pattern:

```
^http://data\.europa\.eu/esco/skill/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$
```

## Warum

Bisher prüfte das Pattern nur das Präfix `…/esco/skill/`. Lieferungen aus
Platzhalter- oder Bootstrap-Indizes (etwa `…/esco/skill/mini/pflegeplanung`)
bestanden die Validierung, obwohl ihre URIs im HR-QDE-Graphen nie mit der
Angebotsseite joinen. Coverage- und Gap-Analyse blieben dann leer, ohne dass
es jemand bemerkte. Ab v0.2.0 scheitern solche Lieferungen sichtbar an der
Validierung: SHACL-valide heißt jetzt auch anschlussfähig.

## Prüfstand-Ergebnis (pyshacl)

| Testfall | v0.1.3 (alt) | v0.2.0 (neu) |
|---|---|---|
| sitzler-demand-example-v0.1.ttl (echte UUIDs) | conform | conform |
| koeppe-supply-example-v0.1.ttl (echte UUIDs) | conform | conform |
| sitzler-demand-example-faulty.ttl | verletzt | verletzt |
| Sitzler-Pipeline-Lieferung mit Mini-URIs | conform | **verletzt** |

## Dokumentation und Werkzeuge

- **README:** neuer Abschnitt "ESCO vocabulary": verbindliche Version
  v1.2.1, Download-Anleitung (esco.ec.europa.eu), UUID-Pflicht. Bisher
  stand die Bezugsquelle nur im privaten Prototyp-Repo und war für die
  Masteranden nicht erreichbar.
- **Specs:** alle drei MASTERAND_*.md nennen im Option-A-Abschnitt jetzt
  Datensatz, Version und UUID-Form als Pflicht.
- **validate.py (neu):** pyshacl-basierte, maßgebliche Prüfung einer
  Lieferung. Hintergrund: Der neosemantics-Validator im Container prüft
  sh:pattern nicht auf IRI-Werten und übersieht darum die UUID-Regel.
  validate.py prüft vollständig; die Limitations im README wurden
  entsprechend aktualisiert.

## Kompatibilität

Lieferungen gegen den Mini-Bootstrap-Index der Säule-C-Pipeline sind ab
dieser Version nicht mehr valide. Erforderlich ist der Voll-ESCO-Index auf
Basis von ESCO v1.2.1 (identisch zur Version im HR-QDE-Graphen). Der alte
Prüfstand bleibt über den Git-Tag `toolkit-v0.1.3-shapes` erreichbar.
