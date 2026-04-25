# mediawiki_on

[English version](README.md)

Ansible-проект для развёртывания `MediaWiki` с `PostgreSQL 16` на `Ubuntu 24.04`.

Что делает проект:

- устанавливает `PostgreSQL 16` и создаёт отдельные базу данных, пользователя и схему для MediaWiki;
- удаляет `Apache`, если он установлен;
- устанавливает `Nginx`, `PHP-FPM` и SSL для MediaWiki;
- загружает `MediaWiki 1.45.3` из официального tarball;
- устанавливает расширение `DarkMode` из указанного tarball `REL1_45`;
- включает встроенный dark mode в Vector 2022;
- включает расширения `Cite` и `EditAccount`;
- настраивает `MediaWiki:Sidebar`;
- выполняет CLI-установку MediaWiki и публикует сайт по пути `/wiki`;
- устанавливает `zabbix-agent2` из официального репозитория Zabbix для `Ubuntu 24.04`.

## Структура

- `site.yml` - основной playbook
- `inventory/hosts.yml` - inventory
- `group_vars/mediawiki/main.yml` - основные переменные
- `group_vars/mediawiki/vault.yml.example` - пример файла с секретами
- `roles/postgresql` - установка и инициализация PostgreSQL
- `roles/mediawiki` - настройка MediaWiki, Nginx, PHP-FPM и SSL
- `roles/zabbix_agent2` - настройка Zabbix Agent 2

## Подготовка

1. Убедитесь, что `Ansible` установлен на управляющей машине. Если его ещё нет, используйте [install_ansible.sh](install_ansible.sh).

2. Установите нужную коллекцию:

```bash
ansible-galaxy collection install -r requirements.yml
```

3. Заполните `inventory/hosts.yml`.

Пример:

```yaml
all:
  children:
    mediawiki:
      hosts:
        wiki01:
          ansible_host: 203.0.113.10
          ansible_user: ubuntu
```

4. Настройте основные переменные в `group_vars/mediawiki/main.yml`:

- `mediawiki_server_name`
- `mediawiki_server_url`
- `mediawiki_wiki_name`
- `mediawiki_admin_user`
- `mediawiki_site_language`
- `mediawiki_darkmode_enabled`
- `mediawiki_darkmode_archive_url`
- `mediawiki_vector_dark_mode_enabled`
- `mediawiki_vector_theme_default`
- `mediawiki_vector_update_existing_users`
- `mediawiki_extra_extensions`
- `mediawiki_sidebar_enabled`
- `zabbix_agent_server`

Для SSL по умолчанию используется самоподписанный сертификат.

- Оставьте `mediawiki_ssl_mode: "selfsigned"`, если нужен автоматически сгенерированный сертификат.
- Используйте `mediawiki_ssl_mode: "provided"` и задайте `mediawiki_ssl_cert_path` и `mediawiki_ssl_key_path`, если у вас уже есть сертификат.
- Если `mediawiki_server_name` содержит IP-адрес, скорректируйте `mediawiki_ssl_subject_alt_name`, например: `IP:203.0.113.10`.

5. Создайте `group_vars/mediawiki/vault.yml` на основе примера:

```bash
cp group_vars/mediawiki/vault.yml.example group_vars/mediawiki/vault.yml
```

Минимальный пример:

```yaml
vault_mediawiki_admin_password: "strong_admin_password"
vault_mediawiki_db_password: "strong_database_password"
```

При необходимости этот файл можно зашифровать через `ansible-vault`.

## Запуск

```bash
ansible-playbook site.yml
```

После выполнения playbook wiki должна быть доступна по адресу:

```text
https://<your-domain-or-ip>/wiki
```

Ссылки на страницы настроены без `index.php`, например:

```text
https://<your-domain-or-ip>/wiki/Заглавная_страница
```

## Настройка

- Версия MediaWiki: `mediawiki_version`
- URL архива MediaWiki: `mediawiki_archive_url`
- URL архива расширения DarkMode: `mediawiki_darkmode_archive_url`; оставьте пустым, чтобы автоматически найти текущий архив `REL1_45` на extdist
- Путь публикации: `mediawiki_script_path`
- Имя базы данных, пользователь и схема: `mediawiki_db_*`
- Версия PostgreSQL: `postgresql_version`
- Режим SSL и пути к сертификатам: `mediawiki_ssl_*`
- Версия Zabbix и параметры агента: `zabbix_*`

## Примечания

- Проект предполагает, что PostgreSQL работает на том же хосте, что и MediaWiki.
- По умолчанию используется MediaWiki версии `1.45.3`.
- Веб-стек по умолчанию: `Nginx + PHP-FPM + HTTPS`.
- `Apache` останавливается и удаляется, если уже установлен на целевом сервере.
- `zabbix-agent2` устанавливается из официального репозитория Zabbix.
- `DarkMode` включён по умолчанию из tarball ветки `REL1_45`, поэтому для совместимости проект использует ветку MediaWiki `1.45.x`.
- MediaWiki поддерживает PostgreSQL, но этот вариант используется реже, чем MariaDB/MySQL, поэтому перед запуском в production стоит отдельно проверить ваши расширения и сценарий обновления.
