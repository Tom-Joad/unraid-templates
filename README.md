# unraid-templates

[Unraid](https://unraid.net) Community Applications templates for the container
images published by [Tom-Joad](https://github.com/Tom-Joad).

| App | What it does | Project |
| --- | --- | --- |
| scanbutler | Turns scanned paper into named, searchable PDFs; splits large stacks by content, feeds Paperless-ngx | [Tom-Joad/scanbutler](https://github.com/Tom-Joad/scanbutler) |
| tdld | yt-dlp on a timer, with a small web UI for the download lists | [Tom-Joad/TDLD](https://github.com/Tom-Joad/TDLD) |
| cf-managed-network-endpoint | TLS endpoint for Cloudflare Zero Trust managed network detection | [Tom-Joad/cf-managed-network-endpoint](https://github.com/Tom-Joad/cf-managed-network-endpoint) |
| ucg-config-backup | Scheduled config backups of a Ubiquiti UCG Ultra over the local UniFi OS API | [Tom-Joad/ucg-config-backup](https://github.com/Tom-Joad/ucg-config-backup) |
| wol-relay-container | HTTP relay that sends Wake-on-LAN magic packets, e.g. for Home Assistant | [Tom-Joad/wol-relay-container](https://github.com/Tom-Joad/wol-relay-container) |

## Support

A question or a bug in an app goes to that app's GitHub issues (linked above
and in each template). A problem with a template itself (a wrong default, a
broken link) goes to this repository's issues.

## Installing without Community Applications

1. In Unraid, open **Docker** → **Add Container**.
2. Under **Template repositories**, add
   `https://github.com/Tom-Joad/unraid-templates` and save.
3. Pick the app from the **Template** list at the top of the page.

## How this repository is built

Each project keeps its own `unraid/<app>.xml` as the source of truth. The
files in `templates/` are copies made by [scripts/sync.sh](scripts/sync.sh);
they differ in two lines:

- `<TemplateURL>` points at the copy in this repository, as Community
  Applications expects.
- `<Icon>` points at the app's icon in `icons/`.

The sync workflow runs the script every day. When a project changed its
template, it opens (or updates) a pull request from `sync/templates`; merging
it publishes the change to Community Applications. It can also be started by
hand from the Actions tab.

The icons are rendered by [icons/src/make_icons.py](icons/src/make_icons.py)
(Anton, SIL Open Font License 1.1). `icon.png` is the publisher mark.

## Licence

[MIT](LICENSE)
