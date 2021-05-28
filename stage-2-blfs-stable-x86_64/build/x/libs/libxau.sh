#! /bin/bash

PRGNAME="libxau"
ARCH_NAME="libXau"

### libXau (Sample Authorization Protocol for X)
# Библиотека, реализующая авторизацию X11

# Required:    xorgproto
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1
source "${ROOT}/xorg_config.sh"                          || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# shellcheck disable=SC2086
./configure        \
    ${XORG_CONFIG} || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Sample Authorization Protocol for X)
#
# The libXau package contains a library implementing the X11 Authorization
# Protocol. This is a very simple mechanism for providing individual access to
# an X Window System display. It uses existing core protocol and library hooks
# for specifying authorization data in the connection setup block to restrict
# use of the display to only those clients that show that they know a
# server-specific key called a "magic cookie."
#
# Home page: https://www.x.org
# Download:  https://www.x.org/pub/individual/lib/${ARCH_NAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
