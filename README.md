# VolumeCalc

Eigenständiger SHK-Rechner zur Ermittlung des Wasserinhalts einer Heizungsanlage. Das Projekt ist als Schwester-App zu MAGCalc aufgebaut.

## Enthalten
- iOS 17+ SwiftUI (`de.kamilunavo.volumecalc`)
- Android 8+ / API 26+ Jetpack Compose (`de.kamilunavo.volumecalc`)
- Rohrvolumen aus echtem Innendurchmesser und Länge
- Fußbodenheizungs-Kreise
- Flachheizkörper-Referenzdaten plus exakte manuelle Herstellerwerte
- Puffer, Wärmeerzeuger, hydraulische Weiche und freie Bauteile
- Projektverwaltung und lokale Speicherung auf iOS und Android
- Planungsreserve getrennt vom real berechneten Anlageninhalt
- Export/Teilen; MAGCalc-Deep-Link-Vertrag für ein späteres MAGCalc-Update dokumentiert
- Unit Tests für Kernformeln

## Fachliche Grundformel
`V[l] = π/4 × d_i²[mm²] × L[m] / 1000`

Heizkörperwerte sind ausdrücklich baureihenspezifische Referenzwerte und kein universeller Ersatz für Herstellerdaten.

## Build iOS
`open AnlagenVolumen.xcodeproj`

## Core Tests
`swift test`

## Android
Ordner `android/` in Android Studio öffnen. Build-Konfiguration nutzt compile/target SDK 36 und AGP 9.3.0. Für AGP 9.3 ist Gradle 9.5+ vorgesehen.
