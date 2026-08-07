# Toolkit v0.3.0 · 2026-08-06

## Säule D kommt hinzu

Das Toolkit deckte bisher die Säulen A, B und C ab. Mit dieser Version
kommt die Harmonisierungsschicht der Säule D dazu: Schema, Shapes, zwei
Beispiel-Lieferungen, Lieferspezifikation und der ESCO-Ausschnitt für
den Informatik-Korridor.

Neue Dateien:

- `ontology/hrqde-harmonisation-schema.ttl`
- `ontology/hrqde-shape-harmonisation.ttl`
- `ontology/esco-skeleton-for-oberhuber.ttl`
- `examples/oberhuber-harmonised-example-v0.2.ttl`
- `examples/oberhuber-harmonised-example-faulty.ttl`
- `specs/MASTERAND_OBERHUBER.md`

## Präfix harm: statt hrqde:

Die Harmonisierungsschicht verwendet das Präfix `harm:` bei
unverändertem Namensraum `http://hr-qde.org/harmonised/`.

Spec v0.1 nannte den Namensraum, aber kein Kürzel. Da `hrqde:` im Graphen
bereits an `http://hr-qde.org/ontology/` gebunden ist, hätte ein Import
unter demselben Kürzel dazu geführt, dass neosemantics ein erzeugtes
Ersatzkürzel vergibt und sämtliche Klassen der Schicht umbenennt. Im
Graphen wären die Klassen als `ns6__HarmonisedConcept` gelandet; `ns0`
bis `ns5` sind bereits an ESCO-Nebennamensräume vergeben.

## Coverage bindet an die Skill-Ebene

Analog zur Vokabularbindung aus v0.2.0 zählen nur Mappings zur Coverage,
deren Objekt ein ESCO-Skill in kanonischer UUID-Form ist.

| Klasse | Objekt | Coverage |
|---|---|---|
| `harm:HubMapping` | `esco/skill/{uuid}` | ja |
| `harm:LevelMapping` | `hrqde:DQR1`–`DQR8` oder `snb/qf-eu-level/{n}` | nein |
| `harm:OccupationMapping` | `esco/occupation/{uuid}` | nein |

Hintergrund: Alle drei Datensäulen referenzieren ESCO-Skills, über
`acquiredCompetenceOf`, `targetsCompetence` und `refersToCompetence`.
ESCO-Berufe tragen im gesamten Graphen genau eine Kante, und die stammt
aus `examples/sitzler-demand-example-v0.1.ttl`. Ein Mapping auf einen
Beruf ist damit zwar über `isEssentialSkillFor` traversierbar, führt
aber auf eine praktisch unbespielte Ebene.

Berufs-Mappings bleiben zulässig, erfordern aber die Klasse
`harm:OccupationMapping` und eine `harm:justification`.

## Niveaus werden referenziert, nicht neu geprägt

`harm:LevelMapping` akzeptiert als Subjekt und Objekt ausschließlich
`hrqde:DQR1` bis `hrqde:DQR8` sowie EQF-Autoritäts-URIs unter
`http://data.europa.eu/snb/qf-eu-level/`.

Das Skelett modelliert die Niveaukorrespondenz bereits, jedes
`hrqde:DQR{n}` trägt einen `skos:exactMatch` auf die EQF-URI. Eine
Lieferung mit eigenen Niveau-URIs wiederholt diese Aussage in einem
Vokabular, das mit nichts verbunden ist, und `targetLevel` aus Säule B
findet sie nicht.

## Shapes zielen ohne RDFS-Inferenz

`hrqde-shape:MappingShape` führt die drei Unterklassen explizit als
`sh:targetClass`, statt sich auf `rdfs:subClassOf` zu verlassen.
`validate.py` läuft mit `inference="none"`, und n10s validiert ebenfalls
ohne RDFS-Schluss. Ohne die expliziten Zielklassen wären Instanzen von
`harm:HubMapping` von keiner Shape erfasst worden.

Für neue Shapes gilt das als Konvention: Zielklassen immer vollständig
aufführen, Unterklassenbeziehungen tragen in der Validierung nicht.

## ESCO-Ausschnitt für den Informatik-Korridor

`ontology/esco-skeleton-for-oberhuber.ttl` enthält 1302 Skill-Konzepte
mit englischen und deutschen Labels sowie 431 `skos:broader`-Kanten
innerhalb des Ausschnitts.

Zusammensetzung: Vereinigung des ICT-Wissenszweigs unter `isced-f/06`
mit 365 Konzepten und des Konzeptschemas „Digital" mit 1290 Konzepten;
Schnittmenge 353. Die Vereinigung wurde gewählt, weil e-CF berufliche
Handlungskompetenzen beschreibt, die im Digital-Schema liegen, während
der Wissenszweig Wissensgebiete führt.

Der Ausschnitt war in Spec v0.1 zugesagt und nicht geliefert worden.

## Hinweis zur Shape-Zusammenführung

`hrqde-shape-harmonisation.ttl` liegt als eigenständiges Modul vor.
`n10s.validation.shacl.import.fetch` überschreibt vorhandene Shape-Sets,
je Datenbank kann nur ein Set aktiv sein. Für den kombinierten Betrieb
ist das Modul in `hrqde-shapes-all.ttl` zu übernehmen. Für die lokale
Validierung einer Säule-D-Lieferung genügt das Modul allein:

```
python validate.py lieferung.ttl ontology/hrqde-shape-harmonisation.ttl
```
