# VolumeCalc — iOS 1.0 (5)

Subtitle DE: Anlageninhalt mit Füllnachweis

Subtitle EN: Water inventory & fill checks

## Beschreibung DE

VolumeCalc verbindet das wasserführende Bauteilinventar einer Anlage mit einem dokumentierten Füllabgleich.

Erfasse Rohrleitungen, Flächenheizung, Heizkörper, Speicher und weitere wasserführende Komponenten. Rohrinhalte werden geometrisch berechnet; für andere Bauteile kannst du Hersteller- oder Messwerte dokumentieren. Quellen und Unsicherheiten lassen sich pro Bauteil ergänzen. Eine Übersicht nach Bauteilart macht den Anlageninhalt nachvollziehbar.

Nach einer vollständigen Befüllung vergleichst du den real eingefüllten Wasserinhalt mit dem Inventar: Zählerstand vorher und nachher, abgelassene Mengen und eine eigene Projekttoleranz. Die berechnete Inventar-Basis wird mit jeder Messung festgehalten und bleibt auch nach späteren Projektänderungen erhalten. Planungsreserven werden separat ausgewiesen und nicht als realer Wasserinhalt gerechnet.

Speichere Projekte lokal und teile einen Bericht mit Bauteilen, Quellen und Füllnachweisen. Der Abgleich setzt eine anfangs leere Anlage und übereinstimmende Systemgrenzen voraus; Nachfüllungen im Betrieb sind dafür ungeeignet. Abweichungen sind keine automatische Leckdiagnose.

Offline nutzbar, ohne Benutzerkonto.

## Review note EN

VolumeCalc now provides an inventory-evidence and complete-fill verification workflow. This is distinct from generic volume calculators and from our pipe pressure-loss, room-capacity, air-commissioning and refrigeration-service products.

The new Füllabgleich tab groups the inventory by component type, lets users document each component's source and records complete fills from meter start/end readings minus drained water. Each record freezes its own calculated inventory baseline; later edits and planning reserves do not rewrite measured history. A report includes original inputs, evidence and differences.

Steps: add a water-filled component in Inventar, then open Füllabgleich. Tap a component to document its data source. Choose Füllabgleich erfassen, enter meter readings and confirm an initially empty system with matching boundaries. Save and review the discrepancy; relaunch to verify persistence. Share the inventory/fill report from Übergabe. No account is required.

Existing saved projects migrate without losing component data. Typography and numeric fields were enlarged, and dense inventory rows stack vertically at accessibility text sizes. The contradictory forced dark/light appearance was corrected.

## Release state

Use these metadata only with the new signed build 5. The original rejected build does not contain the new workflow. See CI and VALIDATION.md for actual verification results. Signed upload requires the existing Apple Developer signing environment; no signing credential has been created or changed.
