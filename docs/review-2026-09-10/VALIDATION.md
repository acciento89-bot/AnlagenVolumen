# Validation — VolumeCalc, 2026-09-10

Validated source commit: `2620d76f4e58ebd66069769f61122d785edd18b7`.

[CI run 33](https://github.com/acciento89-bot/AnlagenVolumen/actions/runs/34451502419) passed all five jobs. This includes the final two-line contrast improvement for component sources and notes; their text now uses the full-opacity primary foreground. The preceding complete workflow also passed in run 31. The final documentation-only commit does not change the tested source or configuration.

## Successful checks

- All 13 core XCTest cases passed, including old-project decoding, net-fill arithmetic, invalid/partial fills and the frozen inventory baseline.
- The existing Android unit tests passed.
- The shipping Xcode project compiled in Debug for the simulator and in unsigned Release for iOS devices.
- The full inventory/fill workflow passed on iPhone 17 Pro and iPad Pro 13-inch (M5), with each family checked independently.

The UI test creates a component inventory, records a 10-litre complete fill with confirmed system boundaries, saves it, terminates and relaunches the app, and verifies that the recorded fill remains visible. It also captures the inventory and fill-verification screens at the largest accessibility text size. Screenshots are retained in the run's device-specific review artifacts.

Environment: GitHub-hosted macOS, Xcode 26.6, iOS 26.4 simulators. This is simulator validation, not physical-device testing or a complete manual accessibility audit.

Earlier failed runs exposed ambiguous native iPad tab elements and a test tap on the confirmation label instead of its actual switch. The final test explicitly verifies the switch state and passes on both families without suppressing failed assertions.

## Distribution state — updated 2026-09-10

Version 1.0, build 5 was distribution-signed and successfully uploaded using the existing App Store Connect credentials in `appideenchatgpt` and GitHub-hosted macOS. The VolumeCalc job succeeded in [the signed upload run](https://github.com/acciento89-bot/appideenchatgpt/actions/runs/34502522012). A later redundant upload attempt was rejected because build 5 already existed; it did not invalidate the successful original upload.

Fresh native iPhone 17 Pro Max and iPad Pro 13-inch screenshots were captured from the same application source in [the screenshot run](https://github.com/acciento89-bot/appideenchatgpt/actions/runs/34502913598). The existing German Store listing received the new screenshots and description. Review notes were updated and the exact VALID build 5 selected.

Apple confirmed `WAITING_FOR_REVIEW` at 17:40 UTC on 2026-09-10 in [the final submission run](https://github.com/acciento89-bot/appideenchatgpt/actions/runs/34509471931), submission `3f07ca86-7f01-4a35-a3e6-2d8d95d52b36`.

The English Store localization could not be created because Apple reports that the name VolumeCalc is already used by another account in that locale. An automatic rename was blocked by approval review. The existing name was retained, and submission completed with the German Store listing. English Store text remains a draft; the app's English interface is included in build 5.

This is a confirmed submission, not Apple approval or publication. No secret values were added to the repository or reports.
