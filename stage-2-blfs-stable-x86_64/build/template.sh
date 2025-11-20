#! /bin/bash

PRGNAME=""

### <PRGNAME> ()

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"


DESTDIR="${TMP_DIR}" ninja install
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share/doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} ()
#
#
#
# Home page:
# Download:
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

# echo -e "\n---------------\nRemoving *.la files..."
# remove-la-files.sh
# echo "---------------"

# MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"

# mkdir build
# cd build || exit 1
# meson             \
#     --prefix=/usr \
#     -D<param>     \
#     ...
#     .. || exit 1
#
# ninja || exit 1

# source "${ROOT}/config_file_processing.sh"             || exit 1
# CONFIG="...."
# if [ -f "${CONFIG}" ]; then
#     mv "${CONFIG}" "${CONFIG}.old"
# fi
# config_file_processing "${CONFIG}"

# https://www.x.org
# source "${ROOT}/xorg_config.sh"                        || exit 1
# # shellcheck disable=SC2086
# ./configure \
#     ${XORG_CONFIG} || exit 1

# SOURCES="${ROOT}/src"
# VERSION="$(find "${SOURCES}" -type f \
#     -name "${SRC_ARCH_NAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
#     rev | cut -d . -f 3- | cut -d - -f 1 | rev)"
#
# BUILD_DIR="/tmp/build-${SRC_ARCH_NAME}-${VERSION}"
# rm -rf "${BUILD_DIR}"
# mkdir -pv "${BUILD_DIR}"
# cd "${BUILD_DIR}" || exit 1
#
# tar xvf "${SOURCES}/${SRC_ARCH_NAME}-${VERSION}"*.tar.?z* || exit 1
# cd "${SRC_ARCH_NAME}-${VERSION}" || exit 1
