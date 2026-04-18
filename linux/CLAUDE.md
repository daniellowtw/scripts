# Scripts

## Adding new installers

Add a recipe directly to `justfile` — keep it simple and inline. Avoid creating separate installer scripts under `lib/installers/`.

A typical recipe downloads a binary, verifies the checksum if available, and moves it to `/usr/local/bin`:

```just
install-mytool:
    #!/usr/bin/env bash
    ARCH=$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')
    VERSION="1.2.3"
    URL="https://example.com/mytool/${VERSION}/mytool-${VERSION}-linux-${ARCH}"
    curl -Lo mytool "$URL"
    chmod +x mytool && sudo mv mytool /usr/local/bin/mytool
    echo "mytool ${VERSION} installed"
```

For tools with GitHub releases, fetch the latest version dynamically:

```just
    VERSION=$(curl -s https://api.github.com/repos/owner/repo/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | cut -c2-)
```
