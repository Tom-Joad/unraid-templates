#!/bin/sh
# Rebuild templates/ from the Unraid templates in the project repositories.
#
# Each project keeps its own unraid/<app>.xml as the source of truth. The copy
# here differs in two lines only: <TemplateURL> points at the copy in this
# repository (Community Applications expects that), and <Icon> points at the
# icon in icons/. Run it after a project changed its template, then commit.
#
# The template is taken from the project's latest release (the tag the
# published image is built from), so an unreleased change on main never
# reaches Community Applications. Without a release (or when the GitHub API
# can't be reached) it falls back to main and says so.
set -eu

OWNER=Tom-Joad
HERE=https://raw.githubusercontent.com/$OWNER/unraid-templates/main

# app  repository  path of the template in that repository
APPS='
scanbutler                   scanbutler                   unraid/scanbutler.xml
tdld                         TDLD                         unraid/tdld.xml
cf-managed-network-endpoint  cf-managed-network-endpoint  unraid/cf-managed-network-endpoint.xml
ucg-config-backup            ucg-config-backup            unraid/ucg-config-backup.xml
wol-relay-container          wol-relay-container          unraid/wol-relay-container.xml
panacontrol                  PanaControl                  unraid/panacontrol.xml
buybutler                    buybutler                    unraid/buybutler.xml
'

cd "$(dirname "$0")/.."

# Latest release tag of a repository; empty when there is none.
latest_tag() {
  curl -fsSL --max-time 30 --retry 3 --retry-all-errors \
    ${GH_TOKEN:+-H "Authorization: Bearer $GH_TOKEN"} \
    "https://api.github.com/repos/$OWNER/$1/releases/latest" 2>/dev/null |
    sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1
}

# Copy one app. Returns non-zero (and leaves templates/<app>.xml untouched)
# when it can't, so one broken project doesn't stop the others.
sync_app() {
  app=$1 repo=$2 path=$3
  ref=$(latest_tag "$repo")
  if [ -z "$ref" ]; then
    ref=main
    echo "$app: no release found, falling back to main" >&2
  fi
  src=https://raw.githubusercontent.com/$OWNER/$repo/$ref/$path
  [ -f "icons/$app.png" ] || { echo "$app: icons/$app.png is missing" >&2; return 1; }
  tmp=$(mktemp)
  err=
  curl -fsSL --max-time 30 --retry 3 --retry-all-errors "$src" -o "$tmp" || err="cannot fetch $src"
  # A truncated download must not count as success: it has to parse as XML.
  [ -n "$err" ] || python3 -c 'import sys, xml.etree.ElementTree as ET; ET.parse(sys.argv[1])' "$tmp" 2>/dev/null || err="$src is not well-formed XML"
  [ -n "$err" ] || grep -q '<TemplateURL>' "$tmp" || err="$src has no <TemplateURL>"
  if [ -n "$err" ]; then
    echo "$app: $err" >&2
    rm -f "$tmp"
    return 1
  fi
  # Drop any icon of its own, then put ours right after the TemplateURL.
  # Written to a temporary file first, so a failure keeps the old copy.
  sed -e '/<Icon>/d' \
      -e "s|<TemplateURL>.*</TemplateURL>|<TemplateURL>$HERE/templates/$app.xml</TemplateURL>\\
  <Icon>$HERE/icons/$app.png</Icon>|" \
      "$tmp" > "$tmp.out" && mv "$tmp.out" "templates/$app.xml"
  rm -f "$tmp" "$tmp.out"
  echo "templates/$app.xml <- $repo/$path@$ref"
}

# Every app is tried; the failures are collected and reported at the end, so
# the workflow can still propose the templates that were copied.
failed=
while read -r app repo path; do
  [ -n "$app" ] || continue
  sync_app "$app" "$repo" "$path" || failed="$failed $app"
done <<EOF
$APPS
EOF

if [ -n "$failed" ]; then
  echo "Not synced:$failed" >&2
  exit 1
fi
