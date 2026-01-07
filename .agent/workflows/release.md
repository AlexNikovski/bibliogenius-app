---
description: Update version across all BiblioGenius repositories (App, Server, Website)
---

This workflow automates the version bump process across the three main repositories.

**Usage:**
Run this workflow providing the new version number.
`@agent /release [VERSION] [BUILD_NUMBER]`
Example: `@agent /release 0.6.3 5` (for version 0.6.3+5)

**Steps:**

1. **Update App (Flutter)**
    - Target: `/Users/federico/Sites/bibliotech/bibliogenius-app/pubspec.yaml`
    - Action: Update `version: [VERSION]+[BUILD_NUMBER]`
    - Target: `/Users/federico/Sites/bibliotech/bibliogenius-app/README.md`
    - Action: Check/Update if version is mentioned (optional)
    - Git: Commit "chore: bump version to [VERSION]+[BUILD_NUMBER]" and Tag "v[VERSION]-alpha.[BUILD_NUMBER]" (or similar scheme)

2. **Update Server (Rust)**
    - Target: `/Users/federico/Sites/bibliotech/bibliogenius/Cargo.toml`
    - Action: Update `version = "[VERSION]"` (or alpha variant)
    - Git: Commit "chore: bump version to [VERSION]"

3. **Update Public Site (Docs/Download Links)**
    - Target: `/Users/federico/Sites/bibliotech/bibliogenius-public/contribute.html`
    - Action: Replace old version string with `v[VERSION]-alpha.[BUILD_NUMBER]` in links and display tags.
    - Git: Commit "chore: update download links to v[VERSION]-alpha.[BUILD_NUMBER]"

4. **Push All**
    - Run `git push` (and `git push --tags`) in all 3 repositories.

**Note:**
This workflow assumes all repositories are cloned in `/Users/federico/Sites/bibliotech/`.
