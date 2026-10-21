#!/bin/bash
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
qa_dir="$(mktemp -d)"
trap 'rm -rf "$qa_dir"' EXIT
if [[ -z "${DEVELOPER_DIR:-}" && -d /Applications/Xcode-27.1-RC.app/Contents/Developer ]]; then
    export DEVELOPER_DIR=/Applications/Xcode-27.1-RC.app/Contents/Developer
fi
xcrun swiftc -parse-as-library "$root"/AnlagenVolumen/Core/*.swift "$root/AnlagenVolumen/ProjectStore.swift" "$root/ci/alternative-store-smoke.swift" -o "$qa_dir/store-smoke"
"$qa_dir/store-smoke"
