# Fuse — downloads

**[Download the latest version →](https://github.com/xelbooks/fuse-releases/releases/latest)**

Fuse is a browser that replaces tabs with groups: the sites you use, kept in
named sets you can see at a glance and open side by side.

Learn more at **[fuse.brandenacity.com](https://fuse.brandenacity.com)**.

## Which file do I want?

| You are on | Download |
| --- | --- |
| Windows 10 or 11 | `Fuse-Setup-<version>.exe` — the normal installer |
| Windows, without installing | `Fuse-Portable-<version>.exe` — runs from the file itself |
| Linux, any distribution | `Fuse-<version>-x86_64.AppImage` |
| Debian or Ubuntu | `Fuse-<version>-amd64.deb` |

The AppImage needs the executable bit before it will start:

```
chmod +x Fuse-*-x86_64.AppImage
```

The `latest.yml`, `latest-linux.yml` and `.blockmap` files are how installed
copies find new versions. There is no reason to download them by hand.

## About the Windows warning

The Windows builds are signed by **Xelbooks LLC**, verified by Microsoft, and
Windows will show that name when you run them.

You may still see *"Windows protected your PC"* on a new version. That is
SmartScreen's reputation check, not a problem with the signature — it clears as
more people install a given build. Choose **More info → Run anyway**.

If a download ever shows a publisher that is *not* Xelbooks LLC, do not run it,
and tell us at team@brandenacity.com.

## Updating

Installed copies update themselves. You do not need to come back here.

## About this repository

This repository holds published builds and nothing else. Fuse is proprietary
software; its source is not public, and no licence to copy, modify or
redistribute these binaries is granted by their presence here.

Published by Xelbooks LLC dba Brandenacity, Fayetteville, North Carolina.
