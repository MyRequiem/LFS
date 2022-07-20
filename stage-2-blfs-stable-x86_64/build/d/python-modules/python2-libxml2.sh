#! /bin/bash

PRGNAME="python2-libxml2"
ARCH_NAME="libxml2"

### python2-libxml2 (Python2 bindings for libxml2)
# Python2 bindings для libxml2

# Required:    python2
#              libxml2
#              icu
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

cd python || exit 1
python2 setup.py build || exit 1
python2 setup.py install --optimize=1 --root="${TMP_DIR}"

source "${ROOT}/stripping.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Python2 bindings for libxml2)
#
# Python2 bindings for libxml2
#
# Home page: http://xmlsoft.org/
# Download:  http://xmlsoft.org/sources/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
