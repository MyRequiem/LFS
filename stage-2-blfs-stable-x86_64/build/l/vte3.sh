#! /bin/bash

PRGNAME="vte3"
ARCH_NAME="vte"

### VTE (terminal emulator widget for use with GTK+3)
# Виджет эмулятора терминала для GTK приложений.

# Required:    gtk+3
#              libxml2
#              pcre2
# Recommended: fast-float           (если не установлен, то будет скачан с Internet)
#              icu
#              gnutls
#              glib
#              gtk4
#              vala
# Optional:    python3-gi-docgen
#              git и make-ca        (для скачивания fast-float если не установлен)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup             \
    --prefix=/usr       \
    --buildtype=release \
    -D _systemd=false || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

# удалим 2 скрипта /etc/profile.d/vte.{csh,sh}, которые не используются в LFS
(
    cd "${TMP_DIR}" || exit 1
    rm -rf "etc"
)

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (terminal emulator widget for use with GTK+3)
#
# VTE is a terminal emulator widget for use with GTK+3. This package contains
# the VTE library, development files a minimal demonstration application 'vte'
# that uses libvte
#
# Home page: https://wiki.gnome.org/Apps/Terminal/VTE
# Download:  https://gitlab.gnome.org/GNOME/${ARCH_NAME}/-/archive/${VERSION}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
