#!/usr/bin/env bash
set -euo pipefail

script="${1:-.github/scripts/capture-android-parity-screenshots.sh}"
bash -n "$script"

python3 - "$script" <<'PY'
import re
import sys
from pathlib import Path

source = Path(sys.argv[1]).read_text()

assert 'readonly launcher_package="com.android.launcher3"' in source
stabilizer = re.search(r'^stabilize_launcher3\(\) \{\n(.*?)^\}', source, re.M | re.S)
assert stabilizer, 'missing stabilize_launcher3'
body = stabilizer.group(1)
assert 'Application Not Responding: $launcher_package' in body
assert 'adb shell am force-stop "$launcher_package"' in body
assert 'Launcher3 ANR remained focused after targeted stabilization.' in body
assert source.count('adb shell am start -W -n "$package_name/.MainActivity"') == 1
assert source.count('stabilize_launcher3') == 2, 'function plus one call required'

guard = re.search(r'^assert_capture_safe\(\) \{\n(.*?)^\}', source, re.M | re.S)
assert guard, 'missing assert_capture_safe'
guard_body = guard.group(1)
assert 'assert_app_foreground' in guard_body
assert 'assert_no_system_dialogs' in guard_body
assert 'Application Not Responding' in source
assert "isn't responding" in source
assert 'keeps stopping' in source

captures = re.findall(
    r"assert_capture_safe\n" r"adb exec-out screencap -p > \"\$output_dir/[^\"]+\.png\"",
    source,
)
assert len(captures) == 2, 'each PNG must have an immediately preceding strict capture guard'
PY
