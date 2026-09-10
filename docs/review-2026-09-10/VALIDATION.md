# Validation — VolumeCalc, 2026-09-10

Validated source commit: `7577ead8d97b60c5f635590a67d306d0ab45dc5b`.

[CI run 31](https://github.com/acciento89-bot/AnlagenVolumen/actions/runs/34448963663) passed all five jobs. The final documentation-only commit does not change the tested source or configuration.

## Successful checks

- All 13 core XCTest cases passed, including old-project decoding, net-fill arithmetic, invalid/partial fills and the frozen inventory baseline.
- The existing Android unit tests passed.
- The shipping Xcode project compiled in Debug for the simulator and in unsigned Release for iOS devices.
- The full inventory/fill workflow passed on iPhone 17 Pro and iPad Pro 13-inch (M5), with each family checked independently.

The UI test creates a component inventory, records a 10-litre complete fill with confirmed system boundaries, saves it, terminates and relaunches the app, and verifies that the recorded fill remains visible. It also captures the inventory and fill-verification screens at the largest accessibility text size. Screenshots are retained in the run's device-specific review artifacts.

Environment: GitHub-hosted macOS, Xcode 26.6, iOS 26.4 simulators. This is simulator validation, not physical-device testing or a complete manual accessibility audit.

Earlier failed runs exposed ambiguous native iPad tab elements and a test tap on the confirmation label instead of its actual switch. The final test explicitly verifies the switch state and passes on both families without suppressing failed assertions.

## Distribution state

The revised app uses iOS version 1.0, build 5. No signed archive, TestFlight upload or App Review submission was produced from this workspace. Debug and unsigned Release builds do not establish distribution signing.

`scripts/archive-for-app-store.sh` is prepared for a Mac with Xcode and the existing Apple Developer signing setup. It requires the developer team ID through `SHK_DEVELOPMENT_TEAM`; no signing key has been created or replaced. The script has been syntax-checked, but its signing/upload steps have not been run here.

Use [APP_REVIEW.md](APP_REVIEW.md) for the new build 5. In App Store Connect, select the uploaded build, update screenshots and metadata, then submit. Existing rejected build 3 does not contain the new fill workflow. Apple's review decision remains outstanding.
