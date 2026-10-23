---
name: sync-openclash-config
description: Sync changed OpenClash Mihomo templates from ~/dotfiles/mihomo to their real Stash or router configurations. Use when asked to sync template.phone.yaml to the user's Stash configuration in iCloud Documents, or template.router.yaml to the OpenClash router identified by OPENCLASH_ROUTER in this skill's .env file. Never restart OpenClash after updating a config unless the user explicitly asks for a restart.
---

# Sync OpenClash config

Keep the canonical templates in `~/dotfiles/mihomo` and apply requested changes only to the corresponding live configuration target.

## Source templates and targets

- Phone source: `~/dotfiles/mihomo/template.phone.yaml`
- Stash phone target directory: `~/Library/Mobile Documents/iCloud~ws~stash~icloud/Documents`
- Router source: `~/dotfiles/mihomo/template.router.yaml`
- Router: SSH destination from `OPENCLASH_ROUTER` in this skill's `.env` (for example, `root@host`); never a hardcoded default
- Router target directory: `/etc/openclash/config/`

Use the user's actual home-directory expansion for `~`. Do not add a backslash before spaces in a quoted path.

The router `.env` is a private local file named `.env` in this skill's directory. It must define exactly one `OPENCLASH_ROUTER=<ssh-destination>` assignment. Never print its value, commit it, pass it through shell history, or include it in the final report. Before connecting, check that the key exists and is assigned non-empty; fail closed if it is missing, malformed, duplicated, or ambiguous.

## General rules

1. Act only on the template the user changed or explicitly asks to apply. Do not infer that both templates should be deployed.
2. Read the source and inspect the destination before changing anything. Confirm the source exists and is readable.
3. Validate YAML syntax with an available local parser before deployment. If validation fails or no suitable validator is available, report that and do not replace a live file.
4. Never overwrite an ambiguous destination. Identify the intended existing live config by its name and contents. If there are multiple plausible phone/router configs, ask which one to update. Do not replace every YAML file in a directory just because it is there.
5. Preserve a timestamped backup of every existing live file before replacing it. Show a concise summary of the source-to-target change and report the exact files changed.
6. Keep credentials out of this skill, shell history, logs, and chat. Prefer existing SSH keys/configuration or an already-available secure credential prompt. Do not place a password in a command argument or script.
7. Never restart OpenClash or another service as part of a config sync. A request to sync or update a config does not authorize a restart; restart only when the user explicitly asks for one.

## Phone template workflow

When `template.phone.yaml` changed or the user requests its application:

1. Inspect the Stash target directory and identify the active configuration by filename and contents. If the target is ambiguous, stop and ask.
2. Validate the template YAML and compare it with the selected configuration.
3. Back up the target alongside the original using a timestamped filename before changing it.
4. Replace the selected live configuration file with the template while preserving its filename.
5. Confirm the written configuration still parses as YAML.

## Router template workflow

When `template.router.yaml` changed or the user requests its application:

1. Resolve the SSH destination from `OPENCLASH_ROUTER` in this skill's local `.env`. If it is missing, empty, malformed, or defined more than once, stop and ask the user to correct the file. Do not substitute a remembered address, a shell variable from another source, or an SSH config alias. Read the assignment without echoing the destination in logs or command arguments. Check that the host is reachable and authentication succeeds using existing credentials/configuration; do not expose a password. If the host is unreachable or authentication is denied, stop without changing the router and report the reason.
2. Inspect `/etc/openclash/config/` remotely and identify the intended existing router config corresponding to the router template. If multiple plausible config files exist or no target can be identified, do not write; ask the user which file to update.
3. Validate the YAML locally. Transfer the new file to a temporary path on the router, validate it there if a YAML parser is available, and compare it with the selected live file.
4. Create a timestamped backup on the router before replacing the live file. Replace only the selected file, preserving its name and permissions where practical.
5. Do not restart OpenClash as part of the sync. If the user explicitly requested a restart, first inspect which service command is available, then restart only the OpenClash service; do not guess a destructive or unrelated service operation.
6. If replacement fails, preserve the backup and report the state clearly; do not claim success. If safe rollback is possible, restore the backup and report that action. If a restart was explicitly requested, check and report its result.

## Reporting

Summarize which template was applied, the exact destination file(s), backup location(s), validation result, and (for router updates) SSH result. State that the restart was skipped unless the user explicitly requested it, in which case report the restart result. If no update was made, state the reason.
