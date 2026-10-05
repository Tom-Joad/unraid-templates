#!/bin/sh
# Rebuild templates/ from the Unraid templates in the project repositories.
#
# Each project keeps its own unraid/<app>.xml as the source of truth. The copy
# here differs in two lines only: <TemplateURL> points at the copy in this
# repository (Community Applications expects that), and <Icon> points at the
# icon in icons/. Run it after a project changed its template, then commit.
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
'

cd "$(dirname "$0")/.."

echo "$APPS" | while read -r app repo path; do
  [ -n "$app" ] || continue
  src=https://raw.githubusercontent.com/$OWNER/$repo/main/$path
  tmp=$(mktemp)
  curl -fsSL "$src" -o "$tmp"
  grep -q '<TemplateURL>' "$tmp" || { echo "$src: no <TemplateURL>" >&2; exit 1; }
  [ -f "icons/$app.png" ] || { echo "icons/$app.png is missing" >&2; exit 1; }
  # Drop any icon of its own, then put ours right after the TemplateURL.
  sed -e '/<Icon>/d' \
      -e "s|<TemplateURL>.*</TemplateURL>|<TemplateURL>$HERE/templates/$app.xml</TemplateURL>\\
  <Icon>$HERE/icons/$app.png</Icon>|" \
      "$tmp" > "templates/$app.xml"
  rm -f "$tmp"
  echo "templates/$app.xml <- $repo/$path"
done
