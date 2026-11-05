# Security policy

## Supported versions

This repository has no releases. What is on `main` is what Community
Applications and Unraid read, so only `main` is supported.

## Reporting a vulnerability

Please do **not** open a public issue for security problems. Report them
privately through GitHub instead: on the
[Security tab](https://github.com/Tom-Joad/unraid-templates/security),
choose **Report a vulnerability**. You will get an answer within a few days.

## Scope

This repository holds only Unraid templates and their icons. In scope are
problems with the templates themselves, for example:

- a template that points to an image other than the project's own
  (`ghcr.io/tom-joad/...`)
- a default that exposes something it shouldn't (a secret field without
  masking, a port or a path that is wider than the app needs)
- a link in a template that leaks information

A vulnerability in an app goes to that app's repository (linked in the
README and in each template), through its own Security tab.

## Supply chain

The files in `templates/` are copies of the templates in the project
repositories, made by the sync workflow and merged through pull requests
after the template check passes. Third-party actions are pinned to commit
SHAs and updated by Dependabot.
