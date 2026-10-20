# VolumeCalc — design alternatives

Human authorization: substantial updates and ASO for all already published apps, with actual Duo validation. This app is next after ArbeitsKlar; no parallel native builds/devices/UI actions. Preserve existing inventory/fill-audit records and all calculation/reference methods.

Each project can retain named design alternatives. An alternative freezes the actual inventory, reserve percentage, project name and capture time as its baseline, then holds a separate proposed component list and reserve percentage. Existing component IDs link changes; new additions receive new IDs. Editing an alternative never mutates actual inventory or earlier fill audits.

Show original versus proposed calculated water volume, separate reserve and planning volume, signed deltas, and added/removed/changed components. Explicitly label the baseline capture date and signal if current inventory has since changed. Share a readable comparison report with baseline/proposed values, component changes, units and reference/manufacturer notes. No claim that a design alternative was physically installed or measured.

Legacy JSON remains decodable through an optional alternatives field. Validate finite nonnegative quantities/volumes/reserves, finite totals, unique component IDs, meaningful name and sane limits before storage/reporting. Existing ProjectStore atomic writes and failed-load protection remain.

Use established SHK ledger design, DE/EN strings, scrollable layouts and existing component-entry UI where safe. Native iPhone/Duo and Android validation, actual gallery images and store readback required before delivery claims. No purchase/restore/redemption transactions; no publication automations.
