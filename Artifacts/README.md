# Artifacts

This folder holds **`FlagsIOS.xcframework`** after you run:

```bash
chmod +x Scripts/sync-binary-from-private.sh
./Scripts/sync-binary-from-private.sh
```

Do **not** commit the `.xcframework` if your policy forbids large binaries in Git; instead attach the zip from the private repo’s `build/` folder to **GitHub Releases** and use `Distribution/Package.binary.url.template.swift` with the HTTPS URL + checksum.
