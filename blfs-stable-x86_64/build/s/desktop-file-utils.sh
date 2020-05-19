#! /bin/bash

PRGNAME="desktop-file-utils"

### Desktop File Utils (Utilities for manipulating desktop files)
# Утилиты командной строки для работы с .desktop файлами

# http://www.linuxfromscratch.org/blfs/view/stable/general/desktop-file-utils.html

# Home page: http://www.freedesktop.org/wiki/Software/desktop-file-utils
# Download:  https://www.freedesktop.org/software/desktop-file-utils/releases/desktop-file-utils-0.24.tar.xz

# Required: glib
# Optional: emacs

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure \
    --prefix=/usr || exit 1

make || exit 1
# пакет не содержит набора тестов
make install
make install DESTDIR="${TMP_DIR}"

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

# создадим директорию для .desktop файлов и создадим/обновим файл кэша для базы
# данных MIME
APPLICATIONS="/usr/share/applications"
install -vdm755 "${APPLICATIONS}"
install -vdm755 "${TMP_DIR}${APPLICATIONS}"
update-desktop-database "${APPLICATIONS}"
update-desktop-database "${TMP_DIR}${APPLICATIONS}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Utilities for manipulating desktop files)
#
# The Desktop File Utils package contains command line utilities for working
# with Desktop entries (.desktop files). These utilities are used by Desktop
# Environments and other applications to manipulate the MIME-types application
# databases and help adhere to the Desktop Entry Specification.
#
# Home page: http://www.freedesktop.org/wiki/Software/${PRGNAME}
# Download:  https://www.freedesktop.org/software/${PRGNAME}/releases/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
