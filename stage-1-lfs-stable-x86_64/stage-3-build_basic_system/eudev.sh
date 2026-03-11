#! /bin/bash

PRGNAME="eudev"

### eudev (dynamic device directory system)
# Диспетчер устройств, который автоматически определяет подключенное
# оборудование (флешки, мышки и т.д.) и создает нужные файлы для работы с ними.

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

Home page: https://github.com/eudev-project/eudev

Переход с UDev: https://forums.gentoo.org/viewtopic-p-7712064.html

Download: https://github.com/eudev-project/eudev/releases/download/v3.2.14/eudev-3.2.14.tar.gz
