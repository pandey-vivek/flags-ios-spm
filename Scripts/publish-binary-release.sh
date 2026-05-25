#!/usr/bin/env bash
# Build FlagsIOS from private Adobe repo, zip it, print checksum + GitHub Release steps.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PRIVATE="${FLAGS_IOS_PRIVATE:-${ROOT}/../flags-ios}"
VERSION="${1:-0.1.0}"
GITHUB_REPO="${GITHUB_REPO:-pandey-vivek/flags-ios-spm}"
ASSET_NAME="FlagsIOS.xcframework.zip"

if [[ ! -d "${PRIVATE}" ]]; then
  echo "error: private flags-ios not found at ${PRIVATE}" >&2
  echo "Set FLAGS_IOS_PRIVATE=/path/to/adobe/flags-ios clone" >&2
  exit 1
fi

echo "==> Building XCFramework (private: ${PRIVATE})"
( cd "${PRIVATE}" && chmod +x Scripts/build-xcframework.sh && ./Scripts/build-xcframework.sh )

ZIP="${PRIVATE}/build/${ASSET_NAME}"
if [[ ! -f "${ZIP}" ]]; then
  echo "error: missing ${ZIP}" >&2
  exit 1
fi

CHECKSUM="$(swift package compute-checksum "${ZIP}")"
RELEASE_URL="https://github.com/${GITHUB_REPO}/releases/download/${VERSION}/${ASSET_NAME}"

echo ""
echo "========== GitHub Release (public repo only) =========="
echo "1. Open https://github.com/${GITHUB_REPO}/releases/new"
echo "2. Tag: ${VERSION}  (create on main)"
echo "3. Attach file: ${ZIP}"
echo "   ($(du -h "${ZIP}" | awk '{print $1}') — do not commit this zip to git if policy forbids)"
echo "4. Publish release"
echo ""
echo "========== Update Package.swift =========="
echo "url:      ${RELEASE_URL}"
echo "checksum: ${CHECKSUM}"
echo ""
echo "Paste checksum into Package.swift binaryTarget, then:"
echo "  git add Package.swift && git commit -m \"Release ${VERSION} binary SPM\" && git push"
echo "  (optional) GitHub UI: tag ${VERSION} if not created with the release"
echo "========================================================"
