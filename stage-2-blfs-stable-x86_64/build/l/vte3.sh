#! /bin/bash

PRGNAME="vte3"
ARCH_NAME="vte"

### VTE (terminal emulator widget for use with GTK+3)
# Программный компонент (виджет) для создания встроенных окон терминала внутри
# обычных программ, основанных на графических библиотеках GTK+3 и GTK4. Именно
# благодаря ему работают вкладки терминала в таких приложениях, как текстовые
# редакторы или файловые менеджеры.

# Required:    libxml2
# Recommended: fast-float           (если не установлен, то будет скачан с Internet)
#              fmt                  (если не установлен, то будет скачан с Internet)
#              icu
#              gnutls
#              glib
#              gtk+3
#              gtk4
#              simdutf              (если не установлен, то будет скачан с Internet)
#              vala
# Optional:    python3-gi-docgen
#              git и make-ca        (оба сразу, для скачивания fast-float, fmt и simdutf если не установлены)

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

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

# удалим 2 скрипта в /etc/profile.d/, которые не используются в LFS
rm -f "${TMP_DIR}/etc/profile.d"/vte.{csh,sh}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
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
