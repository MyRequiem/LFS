#! /bin/bash

PRGNAME="xcb-util-xrm"

### xcb-util-xrm (XCB utility functions for the X resource manager)
# Библиотека использующаяся поверх libxcb и предоставляющая удобные функции и
# интерфейсы, которые делают необработанный протокол X более удобным.

# Required:    libxcb
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/xorg_config.sh"                        || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# shellcheck disable=SC2086
./configure \
    ${XORG_CONFIG} || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (XCB utility functions for the X resource manager)
#
# The XCB util modules provides a number of libraries which sit on top of
# libxcb, the core X protocol library, and some of the extension libraries.
# These experimental libraries provide convenience functions and interfaces
# which make the raw X protocol more usable. Some of the libraries also provide
# client-side code which is not strictly part of the X protocol but which have
# traditionally been provided by Xlib.
#
# Home page: https://github.com/Airblader/${PRGNAME}
# Download:  https://github.com/Airblader/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
