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
| panacontrol | Remote control and live view for LUMIX cameras in the browser: autofocus, recording, ISO | [Tom-Joad/PanaControl](https://github.com/Tom-Joad/PanaControl) |
| buybutler | Remembers which groceries to buy again and why: barcode scan, verdicts, prices, shared shopping list | [Tom-Joad/buybutler](https://github.com/Tom-Joad/buybutler) |

## Support

A question or a bug in an app goes to that app's GitHub issues (linked above
and in each template). A problem with a template itself (a wrong default, a
broken link) goes to this repository's issues.

Security problems with a template: see [SECURITY.md](SECURITY.md).

## Installing without Community Applications

Unraid no longer reads "Template repositories", so add the template by hand:

1. Download the app's file from [templates/](templates/), for example
   `scanbutler.xml`.
2. Copy it to the flash drive: over the network share to
   `\\<UNRAID-IP>\flash\config\plugins\dockerMan\templates-user\`, or from the
   Unraid terminal into `/boot/config/plugins/dockerMan/templates-user/`.
3. Open **Docker** → **Add Container** and pick the app from the **Template**
   list at the top of the page.

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

To render the icons again, install the packages and pass the Anton font
file (for example `Anton-Regular.ttf` from Google Fonts) and the output folder:

```sh
pip install -r icons/src/requirements.txt
python icons/src/make_icons.py Anton-Regular.ttf icons
```

## Licence

[MIT](LICENSE)
