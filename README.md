# flags-ios-spm (public consumer / distribution)

This repo demonstrates how a **public** Swift package can consume the **private** [`flags-ios`](../flags-ios) SDK in two ways:

| Mode | When to use | Private source on client machine? |
|------|----------------|-----------------------------------|
| **A — Path to sibling `flags-ios`** (default `Package.swift`) | Local dev, CI with both repos checked out | Yes (clone of private repo) |
| **B — Binary `FlagsIOS.xcframework` in `Artifacts/`** (`Package.binary.local.swift`) | Public repo without source; clients only resolve binary | No (only the xcframework in this repo or a release URL) |
| **C — Remote binary URL** (`Distribution/Package.binary.url.template.swift`) | GitHub Releases (or CDN) hosts the zip; true “public fetch” | No |

Android analogy:

- **A** ≈ Gradle `implementation(project(":flags-ios"))` or composite build.  
- **B/C** ≈ publishing an AAR/XCFramework to a place SPM can download (Maven / release asset).

---

## Prerequisites

- Repos side by side (default paths):

  ```text
  .../IdeaProjects/flags-ios        ← private SDK
  .../IdeaProjects/flags-ios-spm    ← this public consumer
  ```

- Xcode with iOS SDK (for **Mode B** script that runs `xcodebuild archive`).

---

## Mode A — Quick test (path dependency, no binary)

From **this** repo:

```bash
cd /Users/vivekp/IdeaProjects/flags-ios-spm
swift package resolve
swift build
swift test
```

You should see **FlagsConsumerTests** pass. This proves SPM resolves **`FlagsIOS`** from the **private** package via `../flags-ios` without publishing to Git.

**External clients** would need access to **both** repos if you keep `path:` — so `path:` is only for **your machine / monorepo layout**. For clients, use **Mode B or C**.

---

## Mode B — “Publish binary into public repo” (local simulation)

1. Build the XCFramework in the private repo and copy it here:

   ```bash
   cd /Users/vivekp/IdeaProjects/flags-ios-spm
   chmod +x Scripts/sync-binary-from-private.sh
   ./Scripts/sync-binary-from-private.sh
   ```

2. Switch this package to the binary manifest:

   ```bash
   cp Package.binary.local.swift Package.swift
   ```

3. **Build / test with Xcode + iOS Simulator** (recommended for iOS-only XCFramework):

   - Open `Package.swift` in Xcode  
   - Destination: **iPhone** simulator  
   - **Product → Test**

`swift test` on **macOS** may fail because the XCFramework slices are **iOS / iOS Simulator**, not macOS.

4. **Git**: add `Package.swift` + `Sources/` + `Tests/` + scripts. **Do not** commit `Artifacts/FlagsIOS.xcframework/` if policy forbids large binaries — instead use **Mode C** and attach the zip to a **GitHub Release**.

---

## Mode C — External clients (no private Git access)

1. In **private** `flags-ios`, run `./Scripts/build-xcframework.sh`.
2. Upload **`build/FlagsIOS.xcframework.zip`** to a **public** release URL.
3. Run:

   ```bash
   swift package compute-checksum /path/to/FlagsIOS.xcframework.zip
   ```

4. Copy `Distribution/Package.binary.url.template.swift` → `Package.swift` in **this** repo; set `url` + `checksum`.
5. Tag **this** repo (e.g. `0.1.0`) and push. Clients add:

   ```swift
   .package(url: "https://github.com/YOUR_ORG/flags-ios-spm.git", from: "0.1.0")
   ```

They get **only** the binary + tiny manifest — **no** private source fetch.

---

## Layout

| Path | Role |
|------|------|
| `Package.swift` | Default: `path:` dependency on `../flags-ios` |
| `Package.binary.local.swift` | Binary `path:` template after `sync-binary-from-private.sh` |
| `Scripts/sync-binary-from-private.sh` | Builds private SDK + copies XCFramework to `Artifacts/` |
| `Sources/FlagsConsumer` | Demo library calling `FlagsIOS` APIs |
| `Tests/FlagsConsumerTests` | Proves linkage + behavior |

---

## Push checklist (GitHub `flags-ios-spm`)

```bash
cd /Users/vivekp/IdeaProjects/flags-ios-spm
git add Package.swift Package.binary.local.swift Sources Tests Scripts Distribution Artifacts/README.md .gitignore README.md
git status
git commit -m "Add SPM consumer for FlagsIOS (path + binary flow)"
git push origin main
```

Then tag when you want a consumer-visible version (optional for a demo):

```bash
git tag -a 0.1.0 -m "Public SPM demo 0.1.0"
git push origin 0.1.0
```
