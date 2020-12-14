#! /bin/bash

PRGNAME="python3-dbusmock"
ARCH_NAME="python-dbusmock"

### dbusmock (Python library useful for writing tests)
# Python-библиотека, используемая при написании тестов для программного
# обеспечения, работающего с D-Bus сервисами

# Required:    python3
#              python-dbus
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

python3 setup.py build || exit 1
python3 setup.py install --optimize=1 --root="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Python library useful for writing tests)
#
# A Python library useful for writing tests for software which talks to D-Bus
# services
#
# Home page: https://github.com/martinpitt/python-dbusmock/
# Download:  https://github.com/martinpitt/${ARCH_NAME}/releases/download/${VERSION}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
