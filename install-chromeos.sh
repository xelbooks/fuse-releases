#!/usr/bin/env bash
#
# Fuse — installer for Chromebooks, and for any Debian or Ubuntu machine.
#
# ChromeOS runs Linux apps inside a virtual machine you turn on under
# Settings → Advanced → Developers → Linux development environment. It used to
# install a .deb when you double-clicked it in the Files app, and register the
# app in the launcher for you. Google deprecated both of those in the Baguette
# rewrite that became the default in ChromeOS M147, so a .deb now opens with
# "Debian package installers are no longer supported" and an app installed from
# the terminal never turns up in the launcher.
#
# This script does what that UI used to do:
#   1. downloads the right build for this machine from the public releases page
#   2. installs it, and pulls in anything it depends on
#   3. writes the launcher entry and icons into your own home directory, which
#      is the copy ChromeOS actually reads
#   4. leaves you a plain `fuse` command as a fallback
#
# Run it with:
#   curl -fsSL https://raw.githubusercontent.com/xelbooks/fuse-releases/main/install-chromeos.sh | bash
#
# Nothing here is Chromebook-specific except the closing advice, so it is also
# a fine way to install Fuse on Debian or Ubuntu.
#
# Published by Xelbooks LLC dba Brandenacity. Fuse is proprietary software; see
# https://fuse.brandenacity.com for the terms it is offered under.

set -euo pipefail

REPO="xelbooks/fuse-releases"
PKG="fuse-browser"

bold=$'\033[1m'; dim=$'\033[2m'; red=$'\033[31m'; green=$'\033[32m'; off=$'\033[0m'
say()  { printf '%s\n' "${bold}==>${off} $*"; }
note() { printf '%s\n' "    ${dim}$*${off}"; }
die()  { printf '%s\n' "${red}Stopped:${off} $*" >&2; exit 1; }

# ---------------------------------------------------------------- sanity

[ "$(uname -s)" = "Linux" ] || die "this installs the Linux build, and this is not Linux.
    On a Chromebook, open Terminal (the Linux one) and run it there."

command -v dpkg    >/dev/null 2>&1 || die "this needs a Debian-based system (no dpkg found)."
command -v curl    >/dev/null 2>&1 || die "curl is missing. Run:  sudo apt-get update && sudo apt-get install -y curl"
command -v sudo    >/dev/null 2>&1 || die "sudo is missing, and installing needs it."

case "$(uname -m)" in
  x86_64|amd64)  DEB_ARCH="amd64" ;;
  aarch64|arm64) DEB_ARCH="arm64" ;;
  *) die "Fuse has no build for $(uname -m) yet. Write to team@brandenacity.com and say which machine this is." ;;
esac

# ---------------------------------------------------------------- find the build

say "Looking up the latest release"
api="https://api.github.com/repos/${REPO}/releases/latest"
json="$(curl -fsSL -H 'Accept: application/vnd.github+json' "$api")" \
  || die "could not reach GitHub. Check the Chromebook is online, then try again."

# Pull the download URLs out without needing jq, which Baguette does not ship.
url="$(printf '%s' "$json" \
        | grep -o '"browser_download_url":[[:space:]]*"[^"]*"' \
        | sed 's/.*"\(https[^"]*\)"/\1/' \
        | grep -- "-${DEB_ARCH}\.deb$" \
        | head -n1 || true)"
tag="$(printf '%s' "$json" | grep -o '"tag_name":[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)"$/\1/' | head -n1 || true)"

if [ -z "$url" ]; then
  if [ "$DEB_ARCH" = "arm64" ]; then
    die "this Chromebook has an ARM processor, and ${tag:-the current release} only ships an Intel/AMD build.
    ARM builds are on the way — write to team@brandenacity.com so we can tell you when."
  fi
  die "${tag:-the current release} has no ${DEB_ARCH} .deb in it. Please tell us at team@brandenacity.com."
fi

deb="$(basename "$url")"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

say "Downloading Fuse ${tag}"
note "$deb"
curl -fL --progress-bar -o "${tmp}/${deb}" "$url" || die "the download did not finish. Try again."

# ---------------------------------------------------------------- install

say "Installing"
# ChromeOS gives its Linux user passwordless sudo, so on a Chromebook this
# never prompts. Saying it would ask made a successful install read as a step
# that had somehow been skipped.
note "If a password is asked for, it is the one you set up for Linux."
sudo apt-get update -qq || true

# `apt install ./file.deb` fails inside ChromeOS's Linux VM: apt drops to the
# unprivileged _apt user to read the file and cannot see into the home
# directory. dpkg first, then apt to satisfy anything missing, avoids that.
sudo dpkg -i "${tmp}/${deb}" >/dev/null 2>&1 || true
sudo apt-get -f install -y  >/dev/null 2>&1 || sudo apt-get -f install -y

dpkg -s "$PKG" >/dev/null 2>&1 || die "the package did not install. Run this to see why:
    sudo dpkg -i ${tmp}/${deb}"

# ---------------------------------------------------------------- locate what it installed

files="$(dpkg -L "$PKG" 2>/dev/null || true)"
bin="$(printf '%s\n' "$files" | grep -E '^/usr/bin/' | head -n1 || true)"
[ -n "$bin" ] || bin="$(command -v "$PKG" || true)"
[ -n "$bin" ] || bin="$(printf '%s\n' "$files" | grep -E "/${PKG}$" | grep '^/opt/' | head -n1 || true)"
[ -n "$bin" ] || die "installed, but the Fuse program is not where it was expected. Tell us at team@brandenacity.com."

# Prefer a big icon: the launcher scales down cleanly and up badly.
icon="$(printf '%s\n' "$files" | grep -E '/icons/hicolor/[0-9]+x[0-9]+/apps/.*\.png$' \
         | sort -t/ -k6 -V | tail -n1 || true)"

# ---------------------------------------------------------------- register it with the launcher

apps="${HOME}/.local/share/applications"
entry="${apps}/${PKG}.desktop"
mkdir -p "$apps"

say "Adding Fuse to the launcher"

# Copy the icons under $HOME too. ChromeOS reads the system copy in most cases
# and the home copy in all of them, and the home copy costs a few hundred KB.
if [ -n "$icon" ]; then
  while IFS= read -r png; do
    [ -n "$png" ] || continue
    rel="${png#/usr/share/icons/}"
    dest="${HOME}/.local/share/icons/${rel}"
    mkdir -p "$(dirname "$dest")"
    cp -f "$png" "$dest" 2>/dev/null || true
  done <<< "$(printf '%s\n' "$files" | grep -E '/icons/hicolor/[0-9]+x[0-9]+/apps/.*\.png$' || true)"
fi

# Deleting first matters: ChromeOS caches launcher entries by path and will
# happily keep serving a stale one it has already read.
#
# StartupWMClass is Fuse-browser rather than the Fuse the package ships: the
# window's real WM_CLASS, read off a running copy, is "fuse-browser",
# "Fuse-browser". With the wrong value the desktop cannot tell that the running
# window belongs to the pinned icon, and shows a second, blank one beside it.
rm -f "$entry"
cat > "$entry" <<ENTRY
[Desktop Entry]
Type=Application
Version=1.0
Name=Fuse
GenericName=Web Browser
Comment=A browser that replaces tabs with groups
Exec=${bin} %U
Icon=${icon:-$PKG}
Terminal=false
StartupNotify=true
StartupWMClass=Fuse-browser
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;
ENTRY
chmod 644 "$entry"

command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$apps" >/dev/null 2>&1 || true
command -v gtk-update-icon-cache   >/dev/null 2>&1 && gtk-update-icon-cache -qtf "${HOME}/.local/share/icons/hicolor" >/dev/null 2>&1 || true

# ---------------------------------------------------------------- a one-word command, in case

mkdir -p "${HOME}/.local/bin"
cat > "${HOME}/.local/bin/fuse" <<WRAP
#!/bin/sh
exec ${bin} "\$@"
WRAP
chmod +x "${HOME}/.local/bin/fuse"

case ":${PATH}:" in
  *":${HOME}/.local/bin:"*) ;;
  *)
    for rc in "${HOME}/.bashrc" "${HOME}/.profile"; do
      [ -f "$rc" ] || continue
      grep -q '\.local/bin' "$rc" 2>/dev/null && continue
      printf '\n# added by the Fuse installer\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "$rc"
    done
    ;;
esac

# ---------------------------------------------------------------- done

cat <<DONE

${green}${bold}Fuse ${tag} is installed.${off}

${bold}To find it:${off}
  1. Right-click ${bold}Terminal${off} in the shelf and choose ${bold}Shut down Linux${off}.
     ChromeOS only rebuilds its app list when Linux restarts.
  2. Open the launcher and look for the ${bold}Linux apps${off} folder — Fuse is
     inside it. Searching "Fuse" shows the website shortcut first, which is
     not the same thing.
  3. Right-click Fuse there and choose ${bold}Pin to shelf${off}.

${bold}If it still is not in the launcher${off} — Google is in the middle of
  replacing how Linux works on ChromeOS, and on some builds the launcher no
  longer picks apps up at all. Fuse still runs. Open Terminal and type:

      ${bold}fuse${off}

  Tell us at team@brandenacity.com which ChromeOS version you are on and we
  will keep chasing it.

${bold}To remove Fuse later:${off}
      sudo apt-get remove -y ${PKG} && rm -f "${entry}" "${HOME}/.local/bin/fuse"

DONE
