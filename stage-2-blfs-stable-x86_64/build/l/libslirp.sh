#! /bin/bash

PRGNAME="libslirp"

### libslirp (User Mode Networking Library)
# Сетевая библиотека пользовательского режима, используемая виртуальными
# машинами, контейнерами или различными инструментами

# Required:    glib
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

VERSION="$(echo "${VERSION}" | cut -d v -f 2)"

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup             \
    --prefix=/usr       \
    --buildtype=release \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (User Mode Networking Library)
#
# libslirp is a user mode networking library used by virtual
# machines,containers or varioud tools. It provides a general purpose TCP-IP
# emulator used by virtual machine hypervisors to provide virtual networking
# services
#
# Home page: https://gitlab.freedesktop.org/slirp/${PRGNAME}
# Download:  https://gitlab.freedesktop.org/slirp/${PRGNAME}/-/archive/v${VERSION}/${PRGNAME}-v${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
