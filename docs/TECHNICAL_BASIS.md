# Technische Basis

## Rohrleitungen
Das Volumen wird nicht über pauschale Liter-pro-Meter-Werte geraten, sondern aus dem tatsächlichen Innendurchmesser berechnet:

`V = π/4 × d_i² × L`

In der App werden mm und m so umgerechnet, dass das Ergebnis direkt in Litern ausgegeben wird. Bei Verbund-/PE-X-Rohren sind Dimensionspresets als Komfortwerte gedacht; der tatsächliche Innendurchmesser des Herstellers hat Vorrang.

## Heizkörper
Die mitgelieferte Referenztabelle ist hersteller-/baureihenspezifisch und wird in der Oberfläche auch so gekennzeichnet. Für die exakte Projektberechnung kann der Wasserinhalt eines Heizkörpers jederzeit direkt eingegeben werden.

Referenzdatensatz: Purmo Plan Compact, Wasserinhalt in Liter je laufendem Meter für Typen 10, 11, 21S, 22 und 33 in mehreren Bauhöhen. Beispiel: Typ 22, Bauhöhe 600 mm = 6,6 l/m.

## Reserve
Die prozentuale Reserve wird nicht in den berechneten realen Anlageninhalt hineingerechnet. Sie wird separat als Planungswert angezeigt, damit der Nutzer zwischen Bauteilsumme und Sicherheitsaufschlag unterscheiden kann.


## Quellenstand der Referenzdaten
Geprüft am 24.08.2026. Die aktuelle Purmo-Produktseite bestätigt für Compact Typ 22, Bauhöhe 600 mm und Baulänge 1000 mm einen Wasserinhalt von 6,6 l. Die erweiterte Typ-/Bauhöhen-Tabelle stammt aus der technischen Purmo-Plan-Compact-Dokumentation. Die App kennzeichnet diese Werte deshalb ausdrücklich als hersteller- und baureihenspezifische Referenzdaten.

- Purmo Compact: https://www.purmo.com/de-de/produkte/23727/compact
- Purmo Plan Compact technische Dokumentation: Referenztabelle Wasserinhalt je laufendem Meter (im Projektstand verifiziert)

## MAGCalc-Übergabe
Der vorgesehene Payload lautet `magcalc://heating?systemVolume=<liter>`. Er wird in VolumeCalc noch nicht als aktiver Button ausgeliefert, solange MAGCalc den URL-Handler nicht implementiert. Dadurch bleibt v1.0 ohne tote Navigation store-tauglich.
