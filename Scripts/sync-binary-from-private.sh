#!/usr/bin/env bash
# Copies FlagsIOS.xcframework from the private repo build into this public repo for binary-only SPM.
# Run from flags-ios-spm repo root.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PRIVATE="${FLAGS_IOS_PRIVATE:-${ROOT}/../flags-ios}"
DEST="${ROOT}/Artifacts"

if [[ ! -d "${PRIVATE}" ]]; then
  echo "error: private repo not found at ${PRIVATE}" >&2
  echo "Set FLAGS_IOS_PRIVATE=/path/to/flags-ios if your layout differs." >&2
  exit 1
fi

echo "==> Building XCFramework in private repo: ${PRIVATE}"
( cd "${PRIVATE}" && chmod +x Scripts/build-xcframework.sh && ./Scripts/build-xcframework.sh )

XC="${PRIVATE}/build/FlagsIOS.xcframework"
if [[ ! -d "${XC}" ]]; then
  echo "error: expected ${XC}" >&2
  exit 1
fi

echo "==> Copying into ${DEST}"
rm -rf "${DEST}/FlagsIOS.xcframework"
mkdir -p "${DEST}"
ditto "${XC}" "${DEST}/FlagsIOS.xcframework"

ZIP="${PRIVATE}/build/FlagsIOS.xcframework.zip"
if [[ -f "${ZIP}" ]]; then
  echo "==> Checksum for remote binary SPM (GitHub Releases, etc.):"
  swift package compute-checksum "${ZIP}"
fi

echo ""
echo "Next: cp Package.binary.local.swift Package.swift"
echo "Then: open Package.swift in Xcode, pick an iOS Simulator, and Product → Test"
echo "(swift test on macOS may fail for iOS-only XCFramework — use Xcode + Simulator.)"
