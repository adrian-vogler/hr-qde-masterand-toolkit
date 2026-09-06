# Toolkit v0.3.1-draft · 2026-09-06

## Typisierte Niveaukette für Säule D

Dieser Entwurf präzisiert die in v0.3.0 eingeführte Relation
`harm:hasLevel`:

- `harm:hasLevel` hat die Signatur `harm:CompetenceConcept` →
  `harm:LevelConcept`.
- Die SHACL-Shape prüft beide Rollen explizit, da die Validierung ohne
  RDFS-Inferenz erfolgt.
- Eine e-CF-Dimension-3-Beschreibung wird über `harm:LevelMapping` auf
  einen DQR-Niveauanker bezogen. Sie ist nie ein `harm:HubMapping`.
- Der Entwurf enthält je ein konformes und absichtlich fehlerhaftes
  Beispiel für die Niveaukette sowie den vollständigen Change Request.

Die Änderung lässt v0.2-Lieferungen ohne `harm:hasLevel` unverändert
gültig. Eine v0.3-Lieferung, die diese Kante nutzt, muss die beiden
Rollen mit `rdf:type` an den Konzepten auszeichnen.
