#!/usr/bin/env bash
set -euo pipefail

readonly package_name="de.kamilunavo.volumecalc"
readonly output_dir="$GITHUB_WORKSPACE/android/parity-screenshots"
readonly apk_path="$GITHUB_WORKSPACE/android/app/build/outputs/apk/debug/app-debug.apk"

current_focus() {
  adb shell dumpsys window | grep -E "mCurrentFocus|mFocusedApp" || true
}

wait_for_foreground() {
  local attempt
  local focus
  for attempt in $(seq 1 30); do
    focus="$(current_focus)"
    if [[ "$focus" == *"$package_name"* ]]; then
      return 0
    fi
    sleep 1
  done
  echo 'Timed out waiting for VolumeCalc to become the foreground app.' >&2
  current_focus >&2
  return 1
}

assert_app_foreground() {
  local focus
  focus="$(current_focus)"
  if [[ "$focus" != *"$package_name"* ]]; then
    echo 'VolumeCalc is not the foreground app; refusing to capture a misleading screenshot.' >&2
    printf '%s\n' "$focus" >&2
    return 1
  fi
}

mkdir -p "$output_dir"
adb install -r "$apk_path"
adb shell am force-stop "$package_name"
adb shell am start -n "$package_name/.MainActivity" --ez "$package_name.STORE_SCREENSHOTS" true

wait_for_foreground
sleep 8
assert_app_foreground
adb exec-out screencap -p > "$output_dir/01-inventory.png"

adb shell input tap 810 2180
sleep 3
assert_app_foreground
adb exec-out screencap -p > "$output_dir/02-fill-audit.png"

python3 - "$output_dir" <<'PY'
import hashlib
import struct
import sys
from pathlib import Path

paths = sorted(Path(sys.argv[1]).glob('*.png'))
assert len(paths) == 2, paths
digests = set()
for path in paths:
    data = path.read_bytes()
    assert data[:8] == b'\x89PNG\r\n\x1a\n', path
    width, height = struct.unpack('>II', data[16:24])
    assert (width, height) == (1080, 2400), (path, width, height)
    digests.add(hashlib.sha256(data).hexdigest())
assert len(digests) == 2, 'Screenshots must show distinct real UI states'
PY
