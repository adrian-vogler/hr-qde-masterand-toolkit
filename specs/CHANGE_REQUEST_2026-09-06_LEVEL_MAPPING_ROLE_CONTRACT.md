# Change Request: Typisierte Niveaukette statt HubMapping-Missbrauch

**Status:** Entwurf zur Prüfung  
**Zielversion:** 0.3.1  
**Betroffene Artefakte:** `ontology/hrqde-harmonisation-schema.ttl`, `ontology/hrqde-shape-harmonisation.ttl`  
**Auslöser:** e-CF-Dimension-3-Niveaubeschreibungen sollen in der Säule-D-Lieferung gegen DQR-Niveauanker materialisiert werden.

## Problem

Der v0.3.0-Kommentar zu `harm:hasLevel` verlangt, die e-CF-Dimension-3-Beschreibungen regulär gegen DQR zu klassifizieren. Ein vorgeschlagener Serialisierungspfad machte daraus jedoch `harm:HubMapping`-Records. Das steht im Widerspruch zum existierenden Vertrag:

- Ein `harm:HubMapping` darf ausschließlich auf eine ESCO-Skill-URI zeigen. Nur dieser Typ stellt den Join zu den Säulen A–C her und zählt zur Coverage.
- Ein DQR-Niveauanker ist kein ESCO-Skill. Der e-CF-zu-DQR-Crosswalk kann daher kein HubMapping sein.
- `harm:LevelMapping` ist bereits der zugehörige Mapping-Typ. Seine Shape lässt Quellkonzepte der Harmonisierungsschicht und DQR-/EQF-Anker als Endpunkte zu.
- Die v0.3.0-Dateien deklarieren `harm:CompetenceConcept` und `harm:LevelConcept` als Klassen. Die aktuelle Formalisierung nutzt dagegen das nicht im Schema deklarierte Muster `harm:conceptRole harm:LevelConcept`. Damit ist weder die beabsichtigte OWL-Semantik noch eine prüfbare Rolle gegeben.

## Entscheiderfrage

Soll der Liefervertrag die Niveaukette als eigenen, nicht in die ESCO-Coverage eingehenden Pfad führen? Dieser Change Request beantwortet die Frage mit **ja**, weil nur so die bestehende Trennung von Kompetenzhub und Niveauhub gewahrt bleibt.

## Vorgeschlagenes Modell

```text
e-CF-Dimension-2-Kompetenz
  a harm:CompetenceConcept
  -- harm:hasLevel -->
e-CF-Dimension-3-Beschreibung
  a harm:LevelConcept
  -- SSSOM harm:LevelMapping / skos:closeMatch -->
hrqde:DQR{n}
  -- skos:exactMatch (Skelett) -->
EQF-Autoritäts-URI
```

Die e-CF-Dimension-2-zu-ESCO-Beziehung bleibt separat ein `harm:HubMapping`. Die beiden Ketten dürfen nicht zu einem Mapping-Typ zusammengezogen werden:

| Relation | Typ | Ziel | Coverage |
|---|---|---|---|
| e-CF-Dimension 2 → ESCO-Skill | `harm:HubMapping` | ESCO-Skill | ja |
| e-CF-Dimension 3 → DQR-Anker | `harm:LevelMapping` | `hrqde:DQR1`–`DQR8` | nein |
| DQR-Anker → EQF-Anker | `harm:LevelMapping` | EQF-Autoritäts-URI | nein |

`skos:closeMatch` ist für den normativen e-CF-zu-DQR-Crosswalk angemessen: Eine e-CF-Proficiency-Beschreibung ist keine identische DQR-Qualifikationsstufe, sondern wird normativ auf diese bezogen. Die Provenienz ist `semapv:ManualMappingCuration` und die Konfidenz `1.0`, sofern die CEN-Crosswalk-Tabelle unverändert übernommen wird.

## Änderungen

1. `harm:hasLevel` erhält die OWL-Signatur `harm:CompetenceConcept → harm:LevelConcept`.
2. Die `HasLevelShape` verlangt dieselben Rollen explizit. Die Typen sind nötig, weil die Validatoren ohne RDFS-Inferenz laufen.
3. `harm:conceptRole` wird nicht Teil des Vertrags. Lieferer migrieren beispielsweise
   `harm:conceptRole harm:LevelConcept` zu `a harm:LevelConcept`.
4. `LevelMappingShape` bleibt der strukturelle Endpunktvertrag für separat ausgelieferte SSSOM-Records. Die detaillierten Rollentypen werden im Ontologieartefakt validiert, in dem die referenzierten Konzepte vorliegen.

## Akzeptanzkriterien

- Eine Kompetenz ohne `a harm:CompetenceConcept` darf keine `harm:hasLevel`-Kante führen.
- Ein Ziel ohne `a harm:LevelConcept` darf nicht Objekt einer `harm:hasLevel`-Kante sein.
- Ein `harm:HubMapping` auf `hrqde:DQR{n}` verletzt weiter die HubMappingShape.
- Ein `harm:LevelMapping` von e-CF-Dimension 3 auf `hrqde:DQR{n}` mit `skos:closeMatch` validiert.
- Die acht DQR↔EQF-Records bleiben unverändert `harm:LevelMapping` und referenzieren die Skelett-URIs.
- Level-Mappings erhöhen keine ESCO-Coverage.

## Migration und Kompatibilität

Der Entwurf ist für bestehende v0.2-Lieferungen ohne `harm:hasLevel` kompatibel. Für v0.3-Lieferungen mit Niveaukanten ist eine Datenmigration erforderlich: Die beiden Rollen müssen als RDF-Typen an den Konzepten erscheinen. Es werden weder parallele DQR-Niveau-URIs geprägt noch ESCO-Knoten mit Harmonisierungseigenschaften annotiert.

Die gleichnamigen `owl:Class`-IRIs als Objekt einer unmodellierten `harm:conceptRole`-Kante zu verwenden, ist keine geeignete Übergangsrepräsentation: Es vermischt Klassen- und Rollenwertsemantik und lässt sich mit SHACL nicht verlässlich prüfen.

## Verifikation des Entwurfs

Mit `validate.py` und pySHACL wurde geprüft:

- Das neue Positivbeispiel validiert gegen die v0.3.1-draft-Shape.
- Das Negativbeispiel erzeugt genau einen `ClassConstraintComponent`-Verstoß für ein nicht als `harm:LevelConcept` typisiertes `hasLevel`-Ziel.
- Die bisherige v0.2-Referenzlieferung ohne `hasLevel` bleibt konform.
- Der aktuelle `ecf_level`-Datenstand der Masterarbeit erzeugt erwartungsgemäß 146 Verstöße, weil er die nicht modellierte `harm:conceptRole`-Schreibweise nutzt. Seine Migration auf `rdf:type` ist daher expliziter Bestandteil der Übernahme dieses Change Requests.
