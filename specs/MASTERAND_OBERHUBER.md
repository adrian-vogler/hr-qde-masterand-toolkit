# Lieferspezifikation Säule D — Harmonisierte Basisontologie

**Adressat:** Oberhuber
**Bezugsdokumente:** `hrqde-harmonisation-schema.ttl` · `hrqde-shape-harmonisation.ttl` · `esco-skeleton-for-oberhuber.ttl`
**Version:** 0.2 · 2026-08-06
**Ersetzt:** v0.1 vom 2026-05-14

## Änderungen gegenüber v0.1

Die Spezifikation v0.1 nannte den Namensraum, aber kein Präfix-Kürzel,
und der zugesagte ESCO-Ausschnitt wurde nie geliefert. Beides ist
korrigiert. Neu hinzugekommen sind ein formales Schema, SHACL-Shapes
und zwei Beispiel-Lieferungen.

- **Präfix `harm:`** statt `hrqde:` bei unverändertem Namensraum
- **ESCO-Ausschnitt** liegt bei, 1302 Konzepte des Informatik-Korridors
- **Formales Schema** nach Tabelle 3.13 und 3.14 der Masterarbeit
- **SHACL-Shapes** zur lokalen Validierung vor dem Versand
- **Coverage-Regel** für Mappings auf Skills, Berufe und Niveaus
- **ELM** ist Exportformat, nicht Integrationsschnittstelle (ADR-14)

## 1. Auftrag

Die dreistufige Harmonisierungspipeline vergleicht Kompetenz- und
Qualifikationsreferenzrahmen und erzeugt eine harmonisierte
Basisontologie mit ESCO als Hub-Rahmen. Geliefert werden die
formalisierten Nicht-ESCO-Konzepte, die Mappings in den Hub und die
Behandlung derjenigen Konzepte, für die kein Mapping gefunden wurde.

**Inhaltlicher Scope:** Informatik-Korridor. Die Referenzmenge auf der
ESCO-Seite ist die beiliegende Datei `esco-skeleton-for-oberhuber.ttl`
mit 1302 Skill-Konzepten. Sie ist die Vereinigung aus dem
ICT-Wissenszweig unter `isced-f/06` mit 365 Konzepten und dem
Konzeptschema „Digital" mit 1290 Konzepten; die Schnittmenge umfasst
353 Konzepte.

Diese inhaltliche Beschränkung ist Teil dieser Spec, **nicht** der
SHACL-Validierung. Die Shapes akzeptieren technisch jede kanonische
ESCO-Skill-URI.

## 2. Was geliefert wird

**Drei Artefakte:**

- **`oberhuber-harmonised-ontology-v{version}.ttl`** — die
  formalisierten Konzepte mit Provenienz, die generierten Cluster und
  die Konzepte ohne Entsprechung
- **`oberhuber-mappings-v{version}.ttl`** — die SSSOM-Records
- **`oberhuber-integration-strategy-v{version}.md`** — Strategie und
  Begleitprotokoll

Mappings dürfen alternativ in der Ontologiedatei stehen. Wenn beide
Repräsentationen gewählt werden, also die direkte SKOS-Kante *und* der
reifizierte SSSOM-Record, ist das im Begleitprotokoll zu vermerken,
weil sonst jede Auswertung doppelt zählt.

**Begleitprotokoll:** Lieferdatum, Pipeline-Version, Anzahl Konzepte je
Rahmen, Anzahl Mappings je Typ, Coverage-Quote, bekannte Limitationen.

## 3. Klassen und Relationen

Das Schema folgt Tabelle 3.13 und 3.14 der Masterarbeit. Die Namen sind
unverändert übernommen, nur das Präfix-Kürzel lautet `harm:`.

| Klasse | Bedeutung |
|---|---|
| `skos:Concept` | Basisklasse aller importierten KQR-Konzepte |
| `harm:HarmonisedCluster` | generierter Cluster-Knoten (FZ 2.2) |
| `harm:HarmonisedConcept` | Konzept **ohne** Entsprechung in einem anderen KQR (FZ 3.2) |
| `harm:KQR` | Quellrahmen als Entität, Wertebereich von `derivedFrom` |

`harm:HarmonisedConcept` ist der disjunkte Fall, nicht der Regelfall.
Ein Konzept, das auf ESCO abgebildet werden kann, bleibt ein einfaches
`skos:Concept` mit `harm:derivedFrom`. Im Mini-Artefakt v0.1 trugen
alle fünf Konzepte diesen Typ; korrekt wäre nur
`dqr:L6_SocialCompetence` gewesen.

| Relation | Signatur | Verwendung |
|---|---|---|
| `owl:sameAs` | C → C | Konzeptäquivalenz, ESCO-Präferenz bei Konflikten |
| `rdfs:subClassOf` | C → C | Subsumption und Cluster-Zugehörigkeit |
| `skos:relatedMatch` | C → C | schwacher Anker, ausschließlich manuell |
| `harm:harmonises` | HC → C | Cluster zu seinen Quellkonzepten |
| `harm:derivedFrom` | C → KQR | Provenienz, als IRI nicht als Zeichenkette |

Der Cluster ist ein **Individuum** von `harm:HarmonisedCluster`, keine
`owl:Class`. Eine Klasse als Subjekt einer Relation auf Individuen
verlässt OWL DL.

## 4. Mapping-Typen und Coverage

Im HR-QDE-Graphen treffen sich alle drei Datensäulen auf der
Skill-Ebene: Säule A über `acquiredCompetenceOf`, Säule B über
`targetsCompetence`, Säule C über `refersToCompetence`. ESCO-Berufe
tragen im gesamten Graphen genau eine Kante, und die stammt aus einer
Beispieldatei des Toolkits.

| Klasse | Objekt | Zählt zur Coverage |
|---|---|---|
| `harm:HubMapping` | ESCO-Skill in UUID-Form | ja |
| `harm:LevelMapping` | `hrqde:DQR1`–`DQR8` oder EQF-Autoritäts-URI | nein |
| `harm:OccupationMapping` | ESCO-Beruf in UUID-Form | nein, Begründung erforderlich |

**Niveaus nicht neu prägen.** Das HR-QDE-Skelett modelliert die
Qualifikationsniveaus bereits als `hrqde:DQR1` bis `hrqde:DQR8`, jeweils
mit `skos:exactMatch` auf die EQF-Autoritäts-URI unter
`http://data.europa.eu/snb/qf-eu-level/`. Säule B referenziert diese
URIs über `targetLevel`. Eine Lieferung, die eigene Niveau-URIs prägt,
wiederholt eine Aussage, die das Skelett bereits trifft, in einem
Vokabular, das mit nichts verbunden ist.

**ESCO nicht annotieren.** ESCO-Konzepte werden weder dupliziert noch
mit `harm:`-Properties versehen. Sie werden ausschließlich über
Mappings referenziert. Andernfalls trägt die Referenzvokabular-Schicht
Kurationsartefakte und lässt sich nicht mehr sauber zurückbauen.

## 5. SSSOM-Felder

Verbindlich sind die in Abschnitt 2.2.2 der Masterarbeit genannten
Slots. Der Slot `match_type` wird **nicht** verwendet.

| Slot | Form |
|---|---|
| `subject_id` | IRI |
| `object_id` | IRI |
| `predicate_id` | IRI aus `skos:exactMatch`, `closeMatch`, `broadMatch`, `narrowMatch`, `relatedMatch` |
| `mapping_confidence` | `xsd:decimal`, 0.0 bis 1.0 |
| `mapping_justification` | IRI aus SEMAPV, z. B. `semapv:LexicalMatching` |
| `mapping_tool` | Zeichenkette mit Pipeline-Version |

`predicate_id` als Zeichenkette `"skos:broadMatch"` ist nicht zulässig.
Ein Prädikat in Stringform lässt sich weder per SPARQL noch per Cypher
traversieren.

Ein `sssom:MappingSet` ist der Container und verweist über
`sssom:mappings` auf die einzelnen Mappings. Die Slots `subject_id`,
`object_id` und `predicate_id` gehören an das `sssom:Mapping`, nicht an
das Set.

## 6. Integrationsstrategien

Jede Instanz von `harm:HarmonisedConcept` trägt genau einen Wert:

| Wert | Bedeutung |
|---|---|
| `own_class` | eigene Klasse der Harmonisierungsschicht |
| `attach_to_skeleton` | Anbindung an einen bestehenden Skelett-Knoten |
| `map_to_nearest` | Zuordnung zum nächstliegenden ESCO-Konzept mit Kontextverlust-Vermerk |
| `out_of_scope` | bewusst nicht integriert |

`pending` ist in einer Lieferung nicht zulässig. Unterstriche statt
Bindestriche, weil neosemantics Bindestriche im generierten Cypher als
Subtraktionsoperator liest.

## 7. Format und Konventionen

- **Serialisierungsformat:** Turtle (.ttl), UTF-8 ohne BOM
- **Namensraum:** `http://hr-qde.org/harmonised/`
- **Präfix:** `harm:` — **nicht** `hrqde:`
- **URI-Muster:** `http://hr-qde.org/harmonised/source/{rahmen}/{kennung}`
- **Ontologie-Metadaten:** maschinenlesbar als `owl:Ontology` mit
  `dcterms:created`, `owl:versionInfo`, `dcterms:source`. Angaben nur im
  Kommentarkopf gehen beim Import verloren.

**Zum Präfix:** Im HR-QDE-Graphen ist `hrqde:` an
`http://hr-qde.org/ontology/` gebunden, den Namensraum des Skeletts.
Dasselbe Kürzel für einen zweiten Namensraum führt dazu, dass
neosemantics beim Import ein erzeugtes Ersatzkürzel vergibt und
sämtliche Klassen dieser Schicht umbenennt. Der Namensraum selbst
bleibt unverändert.

**Zu Schrägstrichen in URIs:** In Turtle darf der lokale Namensteil
eines Präfixnamens keinen Schrägstrich enthalten. Für Unterpfade sind
eigene Präfixe zu deklarieren, etwa
`harm-ecf: <http://hr-qde.org/harmonised/source/ecf/>`.

## 8. Lokale Validierung

```
docker compose up -d neo4j
docker cp hrqde-harmonisation-schema.ttl hrqde-neo4j:/var/lib/neo4j/import/
docker cp hrqde-shape-harmonisation.ttl hrqde-neo4j:/var/lib/neo4j/import/
docker cp oberhuber-harmonised-ontology-v0.2.ttl hrqde-neo4j:/var/lib/neo4j/import/
docker compose exec neo4j cypher-shell -u neo4j -p <passwort>
```

In der cypher-shell:

```cypher
CALL n10s.validation.shacl.import.fetch(
  "file:///var/lib/neo4j/import/hrqde-shape-harmonisation.ttl", "Turtle"
);
CALL n10s.rdf.import.fetch(
  "file:///var/lib/neo4j/import/hrqde-harmonisation-schema.ttl", "Turtle"
);
CALL n10s.rdf.import.fetch(
  "file:///var/lib/neo4j/import/oberhuber-harmonised-ontology-v0.2.ttl", "Turtle"
);
CALL n10s.validation.shacl.validate();
```

Alternativ ohne Neo4j, mit pyshacl:

```
pip install pyshacl
pyshacl -s hrqde-shape-harmonisation.ttl -e hrqde-harmonisation-schema.ttl \
        -i rdfs -a -f human oberhuber-harmonised-ontology-v0.2.ttl
```

**Graph-Konfiguration.** Die Zielinstanz läuft mit
`handleMultival: 'ARRAY'` und `keepLangTag: true`. Mehrsprachige
`skos:prefLabel` überleben den Import vollständig und liegen als
`"Anwendungsentwicklung@de"` vor. Auslesen über
`n10s.rdf.getLangValue('de', n.skos__prefLabel)`.

**Zwei Beispiel-Lieferungen** liegen bei:
`oberhuber-harmonised-example-v0.2.ttl` validiert fehlerfrei,
`oberhuber-harmonised-example-faulty.ttl` erzeugt zehn Verstöße, je
einen pro Fehlerklasse.

## 9. Inhaltliche Hinweise (nicht von SHACL geprüft)

- **Kompetenz gegen Beruf:** e-CF beschreibt berufliche
  Handlungskompetenzen. Der ESCO-Wissenszweig unter `isced-f/06` führt
  Wissensgebiete, das Konzeptschema „Digital" die handlungsnahen
  Digitalkompetenzen. Für e-CF-Mappings ist Letzteres in der Regel der
  passendere Anker. Welcher Zweig je Mapping gewählt wurde, gehört in
  die Strategie-Doku.
- **Confidence-Kalibrierung:** Tabelle 2.18 unterscheidet drei
  Crosswalk-Typen. Die Zuordnung eines konkreten Mappings zu einem Typ
  ist zu dokumentieren, damit die Werte interpretierbar bleiben.
- **`skos:relatedMatch`** ist laut Tabelle 3.14 ausschließlich manuell
  zu setzen. Algorithmisch erzeugte Vorschläge dieses Typs sind vor der
  Lieferung zu prüfen.
- **ELM:** Die ELM-kompatible Serialisierung bleibt als zusätzliches
  Exportformat sinnvoll. Als Integrationsschnittstelle zu Säule B ist
  sie nicht tragfähig, weil Säule B Module als
  `hrqde:EducationalModule` mit `hrqde:LearningOutcome` modelliert und
  im Graphen keine ELM-Knoten existieren. Der Join läuft transitiv über
  die gemeinsame ESCO-Skill-URI.

## 10. Warum vor dem Versand validiert wird

Eine Lieferung kann aus einem älteren oder unsynchronisierten
Pipeline-Stand stammen, ohne dass es beim Versand auffällt. Genau das
war beim Mini-Artefakt v0.1 der Fall: Die Datei widersprach an mehreren
Stellen dem Modell, das Kapitel 3 derselben Arbeit beschreibt. Ein
Validierungslauf vor dem Versand fängt das ab und kostet eine Minute.

## 11. Anlaufstellen bei Fragen

- **Architekturentscheidungen, Schema-Änderungen, Erweiterungswünsche:**
  Abstimmung mit Adrian Vogler
- **Inhaltliche oder methodische Fragen zur Masterarbeit:** Abstimmung
  mit Adrian Vogler oder Prof. Dr. Hemmje
