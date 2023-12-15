#! /bin/bash

PRGNAME="python2-pycairo"
ARCH_NAME="pycairo"

### PyCairo (PyCairo Python2 Module)
# Python2 bindings для Cairo

# Required:    cairo
#              python2
# Recommended: no
# Optional:    hypothesis https://hypothesis.readthedocs.io/en/latest/ (для тестов)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${ARCH_NAME}-1.1*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

tar xvf "${SOURCES}/${ARCH_NAME}-${VERSION}"*.tar.?z* || exit 1
cd "${ARCH_NAME}-${VERSION}" || exit 1

python2 setup.py build || exit 1
# пакет не имеет набора тестов
python2 setup.py install --optimize=1 --root="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (PyCairo Python2 Module)
#
# PyCairo provides Python2 bindings to Cairo
#
# Home page: https://${ARCH_NAME}.readthedocs.io/
# Download:  https://github.com/pygobject/${ARCH_NAME}/releases/download/v${VERSION}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
