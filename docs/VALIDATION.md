# Validation – VolumeCalc 1.0 foundation

Stand: 24.08.2026

## Lokal erfolgreich geprüft
- alle iOS-Swift-Quelldateien syntaktisch geprüft
- Swift-Core-Paket mit `swift test`: 5 Tests, 0 Fehler
- Rohrreferenz 16 × 2 / ID 12 mm / 100 m: 11,3097 l
- Kupfer ID 20 mm / 25 m: 7,8540 l
- Heizkörperreferenz Typ 22 / H 600 / L 1000: 6,6 l
- Reserve-/Projektberechnung
- Null-/Negativwert-Clamping
- `project.pbxproj` und `PrivacyInfo.xcprivacy` validiert
- Android/Kotlin-Rechenkern separat kompiliert und mit Referenzwerten geprüft
- Bundle-/Package-ID auf beiden Plattformen: `de.kamilunavo.volumecalc`
- App Store SKU: `volumecalc-001`

## CI-Gates im Repository
- macOS/iOS Simulator Build via `xcodebuild`
- Android Unit Tests via AGP 9.3.0 + Gradle 9.5.0 + JDK 17
- Swift Core Tests

Ein CI-Gate gilt erst als bestanden, wenn GitHub Actions den committed Stand tatsächlich grün ausgeführt hat. Ein TestFlight-Upload gilt erst als erfolgt, wenn der 99-9-Bridge-Workflow erfolgreich signiert und an App Store Connect übertragen hat.
