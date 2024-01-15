#! /bin/bash

PRGNAME="desktop-file-utils"

### Desktop File Utils (Utilities for manipulating desktop files)
# Утилиты командной строки для работы с .desktop файлами. Так же они
# используются средами рабочего стола и другими приложениями для управления
# базами данных MIME-типов и помогают придерживаться спецификации Desktop Entry
# Specification

# Required:    glib
# Recommended: no
# Optional:    emacs

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson                   \
    --prefix=/usr       \
    --buildtype=release \
    .. || exit 1

ninja || exit 1
# пакет не содержит набора тестов
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

### Конфигурация
# Спецификация XDG Base Directory определяет стандартные месторасположения
# данных и файлов конфигурации для приложений. Эти файлы могут быть
# использованы, например, чтобы определить структуру меню и пункты меню на
# рабочем столе и в рабочей среде.
#
# файлы конфигурации: $XDG_CONFIG_DIRS
#                     по умолчанию /etc/xdg
# файлы данных:       $XDG_DATA_DIRS
#                     по умолчанию /usr/share и /usr/local/share
#
# Среды GNOME, KDE и XFCE придерживаются этих настроек.

# если директория /usr/share/applications/ уже существует, то создадим/обновим
# файл кэша для базы данных MIME
#    /usr/share/applications/mimeinfo.cache
APPLICATIONS="/usr/share/applications"
[ -d "${APPLICATIONS}" ] && update-desktop-database "${APPLICATIONS}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Utilities for manipulating desktop files)
#
# The Desktop File Utils package contains command line utilities for working
# with Desktop entries (.desktop files). These utilities are used by Desktop
# Environments and other applications to manipulate the MIME-types application
# databases and help adhere to the Desktop Entry Specification.
#
# Home page: https://www.freedesktop.org/wiki/Software/${PRGNAME}/
# Download:  https://www.freedesktop.org/software/${PRGNAME}/releases/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
