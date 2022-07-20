#! /bin/bash

PRGNAME="cython"
ARCH_NAME="Cython"

### Cython (static compiler for Python)
# Оптимизированный статический компилятор для Python и язык программирования
# Cython (на основе Pyrex)

# Required:    python2
#              python3
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

python2 setup.py build || exit 1
python3 setup.py build || exit 1

python2 setup.py install --optimize=1 --root="${TMP_DIR}"
python3 setup.py install --optimize=1 --root="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (static compiler for Python)
#
# Cython is an optimising static compiler for both the Python programming
# language and the extended Cython programming language (based on Pyrex). It
# makes writing C extensions for Python as easy as Python itself.
#
# Home page: https://cython.org/
# Download:  https://files.pythonhosted.org/packages/d3/38/adc49a5aca4f644e6322237089fdcf194084f5fe41445e6e632f28b32bf7/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
