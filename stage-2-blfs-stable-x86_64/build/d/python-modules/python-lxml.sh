#! /bin/bash

PRGNAME="python-lxml"
ARCH_NAME="lxml"

### python-lxml (Python bindings for libxml2 and libxslt)
# Python bindings для библиотек libxml2 и libxslt

# Required:    python2
#              python3
#              libxslt
# Recommended: no
# Optional:    gdb       (для тестов)
#              valgrind  (для тестов)
#              cssselect (для тестов) https://pypi.org/project/cssselect/

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

python2 setup.py build || exit 1
python2 setup.py install --optimize=1 --root="${TMP_DIR}"

python3 setup.py build || exit 1
python3 setup.py install --optimize=1 --root="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Python bindings for libxml2 and libxslt)
#
# lxml is a Pythonic binding for the libxml2 and libxslt libraries. It is
# unique in that it combines the speed and feature completeness of these
# libraries with the simplicity of a native Python API
#
# Home page: https://${ARCH_NAME}.de/
# Download:  https://files.pythonhosted.org/packages/source/l/${ARCH_NAME}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
