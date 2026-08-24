# PROJECT STATE – VolumeCalc

Stand: 24.08.2026

## Identität
- App-Name: **VolumeCalc**
- iOS Bundle ID: **de.kamilunavo.volumecalc**
- App Store SKU: **volumecalc-001**
- GitHub: `acciento89-bot/AnlagenVolumen`

## v1.0 foundation
- [x] iOS SwiftUI app scaffold
- [x] Android Jetpack Compose scaffold
- [x] shared calculation specification
- [x] pipe volume formula + common presets + custom inner diameter
- [x] FBH calculation
- [x] radiator reference table + manual manufacturer value
- [x] manual equipment volumes
- [x] project total + separate reserve
- [x] local iOS + Android project persistence
- [x] share/export
- [x] MAGCalc deep-link payload documented (UI intentionally inactive until MAGCalc receiver exists)
- [x] privacy manifest / privacy copy
- [x] App Store / Google Play metadata draft
- [x] CI workflow
- [x] unit tests
- [x] dedicated GitHub repository created
- [x] App Store record created with Bundle ID/SKU above

## Next release gates
- [ ] GitHub CI green on committed source
- [ ] 99-9 TestFlight bridge configured for VolumeCalc
- [ ] signed iOS archive + TestFlight upload
- [ ] TestFlight device QA
- [ ] final privacy/support URLs on kamilunavo.com
- [ ] final screenshots/store listing
- [ ] later: enable receiving `magcalc://heating?systemVolume=` in MAGCalc
