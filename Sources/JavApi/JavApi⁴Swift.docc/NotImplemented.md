# Bewusst nicht umgesetzte Java-Technologien

<!--
* SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
* SPDX-License-Identifier: 0BSD
-->

Technologien aus dem Java-Ökosystem, die in JavApi⁴Swift absichtlich nicht portiert werden — mit Begründung und Neubewertungsvorbehalt.

## Übersicht

JavApi⁴Swift verfolgt das Ziel, Java-API so nah wie möglich in reinem Swift abzubilden. Es gibt jedoch Bereiche, in denen eine direkte Portierung weder sinnvoll noch vertretbar ist — weil das zugrundeliegende Konzept fundamentalen Swift-Prinzipien widerspricht, weil die Technologie im Java-Ökosystem selbst als überholt gilt, oder weil der Sicherheits- und Wartungsaufwand den Nutzen bei weitem übersteigt.

Dieses Dokument beschreibt diese Bereiche, erklärt die Entscheidung und hält fest, unter welchen Bedingungen eine Neubewertung sinnvoll wäre.

---

## Java Object Serialization (`java.io.Serializable`)

### Was Java Serialization macht

Java Serialization (`java.io.Serializable`, `ObjectOutputStream`, `ObjectInputStream`) wandelt beliebige Objektgraphen zur Laufzeit per Reflection in einen Bytestrom um und kann diesen wieder zurück in Objekte deserialisieren. Der Mechanismus arbeitet vollständig ohne explizite Typinformation im Code: jedes Objekt, das `Serializable` implementiert (ein leeres Marker-Interface), wird automatisch erfasst. Die Rekonstruktion erfolgt ohne Aufruf eines Konstruktors — über `sun.misc.Unsafe` bzw. JVM-interne Mechanismen.

### Warum wir es nicht umsetzen

**1. Swift hat kein äquivalentes Reflection-System.**
Swifts `Mirror`-API ist bewusst read-only und eingeschränkt. Es gibt keinen Weg, Objekte ohne Konstruktor zu instanziieren — was Java Serialization intern tut. Diese Einschränkung ist kein Versehen, sondern eine Designentscheidung zugunsten von Typsicherheit und Speichersicherheit.

**2. Swift-Typen sind überwiegend Value Types.**
Java Serialization traversiert Objektgraphen mit zyklischen Referenzen. Swifts bevorzugte Datentypen sind `struct` und `enum` — also Value Types ohne Identität. Das Konzept eines gemeinsamen Objektgraphen passt nicht zum Swift-Speichermodell.

**3. Java Serialization ist in Java selbst faktisch deprecated.**
Seit Java 9 gilt der Mechanismus als „legacy". Seit Java 17 gibt es aktive Bestrebungen zur Entfernung (JEP 415 u. a.). Oracle empfiehlt öffentlich, Java Serialization nicht mehr zu verwenden. Eine Technologie zu portieren, von der der Ursprungs-Plattform selbst abrät, wäre ein schlechtes Investment.

**4. Das Sicherheitsrisiko ist fundamental, nicht behebbar.**
`ObjectInputStream.readObject()` kann zur Laufzeit beliebigen Code ausführen — durch manipulierte Byteströme, die Gadget-Chains in geladenen Klassen ausnutzen. Dies war jahrelang einer der häufigsten Remote-Code-Execution-Vektoren in Java-Anwendungen. Eine sichere Implementierung ist mit dem bestehenden Designkonzept nicht möglich.

**5. Swift hat `Codable` als überlegenen Ersatz.**
`Codable` ist explizit, kompilierzeitgeprüft und typsicher. Es erzwingt, dass Entwickler bewusst entscheiden, welche Daten serialisiert werden — genau das Gegenteil des impliziten Reflection-Ansatzes von Java Serialization. Wer Java-Code portiert, der `Serializable` implementiert, sollte `Codable` verwenden oder — wenn keine Serialisierung tatsächlich benötigt wird — das Interface ersatzlos weglassen.

**Was stattdessen zu tun ist:**
- `Serializable`-Implementierungen ersatzlos entfernen, wenn keine externe Persistenz benötigt wird.
- Persistenz über `Codable` (JSON, Plist, etc.) oder strukturierte Formate (Protocol Buffers, MessagePack) realisieren.
- `serialVersionUID`-Felder verwerfen — Swift hat kein entsprechendes Konzept, weil `Codable` Versionierung explizit erzwingt.

### Neubewertung

Wir behalten uns vor, diese Entscheidung jederzeit zu überdenken. Eine Neubewertung wäre angebracht, wenn Swift ein vollständiges, schreibfähiges Reflection-System erhält, das eine sichere und idiomatische Umsetzung ermöglicht — oder wenn ein konkreter Anwendungsfall in JavApi⁴Swift entsteht, der sich mit `Codable` nicht sinnvoll abdecken lässt. Rückmeldungen und Vorschläge dazu sind ausdrücklich willkommen.

---

## Java Remote Method Invocation (RMI, `java.rmi`)

### Was Java RMI macht

Java RMI (`java.rmi`, `java.rmi.server`) ermöglicht es, Methoden auf Objekten aufzurufen, die in einer anderen JVM laufen — transparent, als wären es lokale Aufrufe. Der Mechanismus erzeugt zur Laufzeit Proxy-Objekte (Stubs), überträgt Argumente und Rückgabewerte serialisiert über das Netzwerk, und nutzt dafür intern Java Object Serialization als Transportformat.

### Warum wir es nicht umsetzen

**1. RMI baut auf Java Serialization auf — und erbt alle ihre Probleme.**
Argumente und Rückgabewerte werden als serialisierte Objekte übertragen. Da wir Java Serialization nicht implementieren (siehe oben), fehlt RMI die Grundlage. Eine eigenständige RMI-Implementierung ohne Serialization ist konzeptuell nicht möglich.

**2. RMI ist JVM-gebunden.**
Das RMI-Protokoll setzt implizit voraus, dass beide Seiten — Client und Server — Java-Typen mit demselben Klassenpfad kennen. Es gibt keine neutrale Schnittstellenbeschreibung. Ein Swift-Client, der mit einem Java-RMI-Server spricht, müsste alle Remote-Klassen und ihre Serialization-Form exakt nachbilden. Das widerspricht dem Portierungsansatz von JavApi⁴Swift.

**3. RMI ist auch im Java-Ökosystem weitgehend aufgegeben.**
Seit der Verbreitung von REST, gRPC und modernen Messaging-Systemen wird RMI in neuen Java-Projekten praktisch nicht mehr eingesetzt. Der `rmiregistry`-Dienst und die zugehörigen APIs werden seit Jahren nur noch aus Kompatibilitätsgründen mitgeliefert. Eine Portierung würde erheblichen Aufwand für eine Technologie bedeuten, die selbst in Java-Projekten kaum noch vorkommt.

**4. Moderne Alternativen lösen das eigentliche Problem besser.**
Was RMI leisten sollte — transparente verteilte Kommunikation — wird heute durch Protokolle gelöst, die sprachunabhängig, versionierbar und sicherheitsbewusst sind: gRPC, OpenAPI/REST, WebSockets, Apple's `Network.framework`. Diese Alternativen sind in Swift nativ und idiomatisch nutzbar.

**5. Swift 6 Concurrency macht den Ansatz zusätzlich problematisch.**
RMIs synchrones, blockierendes Aufrufmodell steht im direkten Widerspruch zu Swifts `async/await`-Concurrency-Modell und den Anforderungen von Swift 6. Eine semantisch korrekte Umsetzung, die weder das Swift-Concurrency-Modell bricht noch Deadlocks riskiert, wäre unverhältnismäßig komplex.

**Was stattdessen zu tun ist:**
- Remote-Kommunikation über gRPC (z. B. `grpc-swift`), REST/OpenAPI oder `Network.framework` realisieren.
- RMI-Interfaces in protokollneutrale Swift-Protocols übersetzen und die Kommunikationsschicht unabhängig implementieren.
- `java.rmi.Remote` und `java.rmi.RemoteException` können als leere Marker für die Portierungsphase angelegt werden, sofern sie in Typdeklarationen vorkommen — ohne funktionale Implementierung.

### Neubewertung

Wir behalten uns vor, diese Entscheidung jederzeit zu überdenken. Eine Neubewertung wäre angebracht, wenn ein konkreter Anwendungsfall entsteht, in dem JavApi⁴Swift-Nutzer RMI-Interoperabilität mit bestehenden Java-Servern benötigen — zum Beispiel als schmaler Adapter-Layer für Legacy-Systeme. In diesem Fall würde eine Neubewertung insbesondere prüfen, ob eine minimale, auf einem modernen Transportprotokoll basierende Brücke sinnvoller wäre als eine vollständige RMI-Portierung. Rückmeldungen und Vorschläge dazu sind ausdrücklich willkommen.

---

## Weitere Bereiche

Dieses Dokument wird fortlaufend ergänzt, wenn weitere Technologien aus dem Java-Ökosystem bewertet und bewusst ausgeschlossen werden.
