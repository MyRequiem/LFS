#! /bin/bash

PRGNAME="libxdmcp"
ARCH_NAME="libXdmcp"

### libXdmcp (X Display Manager Control Protocol library)
# Библиотека, реализующая X Display Manager Control Protocol для взаимодействия
# клиентов с X Display Manager

# Required:    xorgproto
# Recommended: no
# Optional:    --- для сборки документации ---
#              xmlto
#              fop
#              libxslt
#              xorg-sgml-doctools  (https://gitlab.freedesktop.org/xorg/doc/xorg-sgml-doctools)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1
source "${ROOT}/xorg_config.sh"                          || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# shellcheck disable=SC2086
./configure        \
    ${XORG_CONFIG} \
    --docdir="${XORG_PREFIX}/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (X Display Manager Control Protocol library)
#
# The libXdmcp package contains a library implementing the X Display Manager
# Control Protocol. This is useful for allowing clients to interact with the X
# Display Manager.
#
# Home page: https://www.x.org
# Download:  https://www.x.org/pub/individual/lib/${ARCH_NAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
