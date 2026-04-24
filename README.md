# mediawiki_on

[Русская версия](README.ru.md)

Ansible project for deploying `MediaWiki` with `PostgreSQL 16` on `Ubuntu 24.04`.

What this project does:

- installs `PostgreSQL 16` and creates a dedicated database, user, and schema for MediaWiki;
- removes `Apache` if it is present;
- installs `Nginx`, `PHP-FPM`, and SSL for MediaWiki;
- downloads `MediaWiki 1.45.3` from the official tarball;
- installs the `DarkMode` extension from the provided `REL1_45` tarball;
- runs the MediaWiki CLI installer and publishes the site under `/wiki`;
- installs `zabbix-agent2` from the official Zabbix repository for `Ubuntu 24.04`.

## Structure

- `site.yml` - main playbook
- `inventory/hosts.yml` - inventory
- `group_vars/mediawiki/main.yml` - main variables
- `group_vars/mediawiki/vault.yml.example` - example secrets file
- `roles/postgresql` - PostgreSQL installation and initialization
- `roles/mediawiki` - MediaWiki, Nginx, PHP-FPM, and SSL setup
- `roles/zabbix_agent2` - Zabbix Agent 2 setup

## Preparation

1. Make sure `Ansible` is installed on the control machine. If it is not installed yet, use [install_ansible.sh](install_ansible.sh).

2. Install the required collection:

```bash
ansible-galaxy collection install -r requirements.yml
```

3. Fill in `inventory/hosts.yml`.

Example:

```yaml
all:
  children:
    mediawiki:
      hosts:
        wiki01:
          ansible_host: 203.0.113.10
          ansible_user: ubuntu
```

4. Adjust the main variables in `group_vars/mediawiki/main.yml`:

- `mediawiki_server_name`
- `mediawiki_server_url`
- `mediawiki_wiki_name`
- `mediawiki_admin_user`
- `mediawiki_site_language`
- `mediawiki_darkmode_enabled`
- `mediawiki_darkmode_archive_url`
- `zabbix_agent_server`

For SSL, the project uses a self-signed certificate by default.

- Keep `mediawiki_ssl_mode: "selfsigned"` for an auto-generated certificate.
- Use `mediawiki_ssl_mode: "provided"` and set `mediawiki_ssl_cert_path` and `mediawiki_ssl_key_path` if you already have a certificate.
- If `mediawiki_server_name` is an IP address, change `mediawiki_ssl_subject_alt_name` accordingly, for example `IP:203.0.113.10`.

5. Create `group_vars/mediawiki/vault.yml` from the example:

```bash
cp group_vars/mediawiki/vault.yml.example group_vars/mediawiki/vault.yml
```

Minimal example:

```yaml
vault_mediawiki_admin_password: "strong_admin_password"
vault_mediawiki_db_password: "strong_database_password"
```

You can encrypt this file with `ansible-vault` if needed.

## Run

```bash
ansible-playbook site.yml
```

After the playbook finishes, the wiki should be available at:

```text
https://<your-domain-or-ip>/wiki
```

## Customization

- MediaWiki version: `mediawiki_version`
- MediaWiki archive URL: `mediawiki_archive_url`
- DarkMode extension archive URL: `mediawiki_darkmode_archive_url`
- Publish path: `mediawiki_script_path`
- Database name, user, and schema: `mediawiki_db_*`
- PostgreSQL version: `postgresql_version`
- SSL mode and certificate paths: `mediawiki_ssl_*`
- Zabbix version and agent settings: `zabbix_*`

## Notes

- The project assumes PostgreSQL runs on the same host as MediaWiki.
- The default MediaWiki version is `1.45.3`.
- The default web stack is `Nginx + PHP-FPM + HTTPS`.
- `Apache` is stopped and purged if it is already installed on the target host.
- `zabbix-agent2` is installed from the official Zabbix repository.
- `DarkMode` is enabled by default from the `REL1_45` tarball, so the project keeps MediaWiki on the `1.45.x` branch for compatibility.
- MediaWiki supports PostgreSQL, but it is less commonly used than MariaDB/MySQL, so test your extensions and upgrade flow before using this in production.
