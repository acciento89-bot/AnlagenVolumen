#!/usr/bin/env bash
set -euo pipefail

readonly package_name="de.kamilunavo.volumecalc"
readonly output_dir="$GITHUB_WORKSPACE/android/parity-screenshots"
readonly apk_path="$GITHUB_WORKSPACE/android/app/build/outputs/apk/debug/app-debug.apk"

wait_for_text() {
  local expected="$1"
  local attempt
  for attempt in $(seq 1 30); do
    adb shell uiautomator dump /sdcard/window.xml >/dev/null 2>&1 || true
    if adb shell cat /sdcard/window.xml 2>/dev/null | grep -Fq "$expected"; then
      return 0
    fi
    sleep 1
  done
  echo "Timed out waiting for real app UI: $expected" >&2
  adb shell dumpsys activity activities | sed -n '1,120p' >&2 || true
  return 1
}

reject_system_dialog() {
  adb shell uiautomator dump /sdcard/window.xml >/dev/null 2>&1 || true
  if adb shell cat /sdcard/window.xml 2>/dev/null | grep -Eqi "isn't responding|responding|reagiert nicht|keine rückmeldung"; then
    echo 'System dialog would invalidate the store screenshot.' >&2
    return 1
  fi
}

assert_app_foreground() {
  if ! adb shell dumpsys window windows | grep -E "mCurrentFocus|mFocusedApp" | grep -Fq "$package_name"; then
    echo 'VolumeCalc is not the foreground app; refusing to capture a misleading screenshot.' >&2
    adb shell dumpsys window windows | grep -E "mCurrentFocus|mFocusedApp" >&2 || true
    return 1
  fi
}

mkdir -p "$output_dir"
adb install -r "$apk_path"
adb shell am force-stop "$package_name"
adb shell am start -n "$package_name/.MainActivity" --ez "$package_name.STORE_SCREENSHOTS" true

wait_for_text 'ANLAGENINVENTAR'
reject_system_dialog
assert_app_foreground
adb exec-out screencap -p > "$output_dir/01-inventory.png"

adb shell input tap 810 2180
wait_for_text 'VOLUMEN NACHWEISEN'
reject_system_dialog
assert_app_foreground
adb exec-out screencap -p > "$output_dir/02-fill-audit.png"

test "$(sha256sum "$output_dir"/*.png | cut -d' ' -f1 | sort -u | wc -l | tr -d ' ')" -eq 2
