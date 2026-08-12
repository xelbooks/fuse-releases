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
| A Chromebook | one command — see below |

The AppImage needs the executable bit before it will start:

```
chmod +x Fuse-*-x86_64.AppImage
```

The `latest.yml`, `latest-linux.yml` and `.blockmap` files are how installed
copies find new versions. There is no reason to download them by hand.

## Chromebooks

Fuse runs on a Chromebook through the Linux environment Google builds into
ChromeOS. Google deprecated the click-to-install path for Linux apps in the
Baguette rewrite that became the default in ChromeOS M147, so a `.deb` now
opens with *"Debian package installers are no longer supported"* — and an app
installed by hand never turns up in the launcher. Installing is one command
instead.

**1. Turn Linux on.** Settings → About ChromeOS → Developers → **Linux
development environment** → **Turn on**. Accept the defaults. After a few
minutes it opens a black window called Terminal.

**2. Paste this into Terminal and press Enter.**

```
curl -fsSL https://raw.githubusercontent.com/xelbooks/fuse-releases/main/install-chromeos.sh | bash
```

Most Chromebooks will not ask for a password; if yours does, it is the one you
just set up for Linux, and typing shows nothing on screen. [Read the script
first](install-chromeos.sh) if you
would rather; it downloads the same build as the table above, installs it, and
adds Fuse to the launcher.

**3. Restart Linux.** Right-click **Terminal** in the shelf → **Shut down
Linux**. ChromeOS only rebuilds its list of apps when Linux restarts.

**4. Open the launcher** and look inside the **Linux apps** folder. Right-click
Fuse and choose **Pin to shelf**. Searching "Fuse" turns up the website
shortcut first, which is not the same thing.

If Fuse is not in the launcher at all, it is still installed and still runs —
open Terminal and type `fuse`. Google is midway through replacing how Linux
works on ChromeOS and some versions no longer list Linux apps. Tell us at
team@brandenacity.com which ChromeOS version you are on.

Chromebooks with an Intel or AMD processor are covered today. ARM Chromebooks
are not built yet; the installer says so rather than installing the wrong file.

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
