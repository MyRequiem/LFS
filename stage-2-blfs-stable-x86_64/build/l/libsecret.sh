#! /bin/bash

PRGNAME="libsecret"

### libsecret (library to access the Secret Service API)
# Библиотека на основе GObject для доступа к Secret Service API

# Required:    glib
#              gnome-keyring            (runtime)
# Recommended: libgcrypt или gnutls
#              vala
# Optional:    python3-gi-docgen        (для сборки документации)
#              docbook-xml
#              docbook-xsl
#              libxslt                  (для сборки man-страниц)
#              valgrind                 (для тестов)
#              tpm2-tss                 (https://github.com/tpm2-software/tpm2-tss)
#              --- для тестов ---
#              python3-dbus
#              gjs
#              python3-pygobject3

### NOTE:
# Все пакеты, использующие libsecret, ожидают, что gnome-keyring установлен в
# системе

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir bld
cd bld || exit 1

meson setup             \
    --prefix=/usr       \
    --buildtype=release \
    -D gtk_doc=false    \
    .. || exit 1

ninja || exit 1
DESTDIR="${TMP_DIR}" ninja install

# тестирование нужно проводить только после установки пакета в систему и при
# запущенном сеансе Xorg с помощью dbus-launch
# dbus-run-session ninja test

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (library to access the Secret Service API)
#
# The libsecret package contains a GObject based library for accessing the
# Secret Service API
#
# Home page: https://wiki.gnome.org/Projects/Libsecret
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
