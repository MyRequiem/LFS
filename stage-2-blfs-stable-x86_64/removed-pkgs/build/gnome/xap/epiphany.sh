#! /bin/bash

PRGNAME="epiphany"

### Epiphany (GNOME Web Browser)
# Легковесный и минималистичный веб-браузер от проекта GNOME (сейчас официально
# называется GNOME Web), основанный на движке WebKitGTK, созданный для простого
# серфинга и интеграции с рабочим столом GNOME, с фокусом на чистоту интерфейса
# и отсутствие лишних функций.

# Required:    gcr4
#              gnome-desktop
#              iso-codes
#              json-glib
#              libadwaita
#              libportal
#              nettle
#              webkitgtk            (собранный с gtk4)
#              --- runtime ---
#              gnome-keyring        (для хранения паролей)
#              seahorse             (для управления сохраненными паролями)
# Recommended: no
# Optional:    appstream-glib
#              granite              (https://github.com/elementary/granite)

### NOTE:
# перед обновлением пакета, старую версию браузера нужно удалить из системы

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup             \
    --prefix=/usr       \
    --buildtype=release \
    .. || exit 1

ninja || exit 1
DESTDIR="${TMP_DIR}" ninja install

# тесты проводятся после установки пакета в систему
# ninja test

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# обновим файлы схем GLib
glib-compile-schemas /usr/share/glib-2.0/schemas

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GNOME Web Browser)
#
# Epiphany is a simple yet powerful GNOME web browser targeted at non-technical
# users. Its principles are simplicity and standards compliance
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
