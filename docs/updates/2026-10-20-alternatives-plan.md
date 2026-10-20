# Implementation plan

1. Inspect complete project/editor/export architecture and Android persistence; settle a model sharing no mutable references with actual inventory. Add failing core tests for snapshot independence, differences, totals/reserve, invalid values and legacy JSON; implement pure models/report.
2. Add atomic persistence validation and baseline/proposal selection/editing UI, safe deletion confirmation, explicit stale-baseline note and native share output. Reuse existing entry controls, preserve original inventory/fill checks.
3. Implement equivalent Android model, persistence and native UI with migration tests. Keep existing formulas and data sources unchanged.
4. Independent whole-change review; one serial device at a time for genuine iPhone/Android/Duo flows, clean every disposable device. No unverified Duo claim.
5. Verify actual store versions before meaningful versioning; prepare accurate DE/EN ASO and genuine screenshots; signed delivery within published-app scope. Leave unpublished Apple apps and existing pending submissions protected.

Ruling: use this dedicated clean repository on isolated feature branch instead of the chat worktree tool, which cannot select a separate repository. Base4bd299297f03b90c336d49f891f93f5492257fa2 confirmed origin/main. No native execution while root's ArbeitsKlar XCTest owns the device.
