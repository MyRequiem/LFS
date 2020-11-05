#! /bin/bash

PRGNAME=""

### <PRGNAME> ()


# Download:

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"



source "${ROOT}/stripping.sh" || exit 1
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

# source "${ROOT}/config_file_processing.sh"             || exit 1
# CONFIG="...."
# if [ -f "${CONFIG}" ]; then
#     mv "${CONFIG}" "${CONFIG}.old"
# fi
# config_file_processing "${CONFIG}"

