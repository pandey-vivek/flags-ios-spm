# Private Adobe SDK + public GitHub consumer

## The constraint

| Repo | Where it lives | Who can access |
|------|----------------|----------------|
| **flags-ios** | Adobe Git (`git.corp.adobe.com/...`) | Adobe engineers + CI with corp access |
| **flags-ios-spm** | Personal/public GitHub (`pandey-vivek/flags-ios-spm`) | Everyone (external clients) |

**You cannot** put `flags-ios` source on public GitHub and **you cannot** point public `Package.swift` at Adobe Git for external clients — they have no credentials.

**You can** mirror the **Android pattern**: build the SDK in private, publish an **artifact** to a place clients can download without Adobe access.

On iOS with SPM, that artifact is **`FlagsIOS.xcframework.zip`** attached to a **GitHub Release** on the **public** repo, with a tiny `Package.swift` that only contains `.binaryTarget(url:checksum:)`.

---

## Architecture (target state)

```text
[Adobe private] flags-ios (source, tests, CI)
        |
        |  xcodebuild → FlagsIOS.xcframework.zip  (on a Mac with Xcode)
        v
[Public GitHub] flags-ios-spm
        ├── Package.swift          → binaryTarget → Release zip URL
        ├── Sources/FlagsConsumer  → optional wrapper (source in public repo)
        └── Releases/0.1.0/FlagsIOS.xcframework.zip

[External client] aepsdk-flags-ios / customer app
        └── SPM: .package(url: "https://github.com/pandey-vivek/flags-ios-spm.git", from: "0.1.0")
            └── import FlagsIOS / FlagsConsumer   (no Adobe Git)
```

Same intent as:

- **Private:** `fg-mobile-sdk` → Maven Artifactory (Adobe)  
- **Public / client:** extension or consumer depends on a **published** artifact, not the private source tree  

---

## Roles of each repo

### Private `flags-ios` (Adobe)

- All implementation, unit tests, versioning (`FlagsIOSVersion.current`).
- Tag releases internally (e.g. `1.0.0`) on Adobe Git for traceability.
- **Never required** on external machines.

### Public `flags-ios-spm` (GitHub)

- **No dependency** on Adobe Git in `Package.swift`.
- **`Package.swift`** uses **binary SPM** pointing at a **release asset** on this repo.
- Optional thin Swift wrapper (`FlagsConsumer`) that calls into the binary `FlagsIOS` module.
- **This** is what external clients add in Xcode.

---

## Release workflow (each SDK version)

On a Mac with Xcode and a clone of **private** `flags-ios`:

```bash
cd /path/to/flags-ios-spm
chmod +x Scripts/publish-binary-release.sh
./Scripts/publish-binary-release.sh 0.1.0
```

The script:

1. Builds the XCFramework from **private** `flags-ios`.
2. Prints **checksum** and **release URL**.
3. You upload the zip via **GitHub → Releases → New release** (tag `0.1.0`, attach `FlagsIOS.xcframework.zip`).
4. Update **`Package.swift`** `checksum:` (and `url:` if version changed), commit, push.

External clients then resolve **`flags-ios-spm` tag `0.1.0`** only.

---

## Who uses what

| Audience | flags-ios (Adobe) | flags-ios-spm (GitHub) |
|----------|-------------------|-------------------------|
| SDK team | clone, develop, tag | run publish script, upload release |
| Adobe extension (`aepsdk-flags-ios`) | direct corp Git or local path | optional; can depend on corp source **or** public binary |
| **External clients** | **no access** | SPM URL + version only |

### Adobe internal extension (two valid options)

**A — Source from Adobe (like Gradle from Artifactory):**

```swift
.package(url: "git@git.corp.adobe.com:floodgate/flags-ios.git", from: "1.0.0")
```

Requires corp SSH/credentials in Xcode and CI.

**B — Same as external (binary from public GitHub):**

```swift
.package(url: "https://github.com/pandey-vivek/flags-ios-spm.git", from: "0.1.0")
```

No private SDK fetch; uses the same binary customers use (good for parity testing).

---

## Local development on your laptop

| Goal | Command |
|------|---------|
| Edit SDK + consumer with source | `cp Package.path.local.swift Package.swift` (sibling `../flags-ios`) |
| Test public consumer layout | `./Scripts/publish-binary-release.sh 0.1.0` → update checksum → `swift package resolve` |

Do **not** commit `Package.path.local.swift` as the default on `main` if you want external SPM to work.

---

## What does **not** work (and why you saw SPM errors)

- Public `flags-ios-spm` with `.package(path: "../flags-ios")` → fails for anyone who only clones GitHub.
- Public `flags-ios-spm` with `.package(url: "https://github.com/.../flags-ios")` if **flags-ios is not on GitHub** → fails.
- Public `flags-ios-spm` with `.package(url: "git.corp.adobe.com/...")` → **external clients cannot resolve**.

---

## Stage vs prod

Use **different tags** on the **public** repo only (built from different Adobe tags):

- `0.1.0-beta.1` → staging binary zip + `Package.swift` branch or tag  
- `1.0.0` → production  

Adobe `flags-ios` tags stay on corp Git; each public release re-runs `publish-binary-release.sh` from the matching Adobe commit.
