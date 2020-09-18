#! /bin/bash

PRGNAME="cython"
ARCH_NAME="Cython"

### Cython (static compiler for Python)
# Оптимизированный статический компилятор для Python и язык программирования
# Cython (на основе Pyrex).

# нет в BLFS

# Home page: https://cython.org/
# Download:  https://files.pythonhosted.org/packages/49/8a/6a4135469372da2e3d9f88f71c6d00d8a07ef65f121eeca0c7ae21697219/Cython-0.29.16.tar.gz

# Required: no
# Optional: no

ROOT="/root"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

python2 setup.py build || exit 1
python3 setup.py build || exit 1

python2 setup.py install --optimize=1 --root="${TMP_DIR}"
python3 setup.py install --optimize=1 --root="${TMP_DIR}"

cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (static compiler for Python)
#
# Cython is an optimising static compiler for both the Python programming
# language and the extended Cython programming language (based on Pyrex). It
# makes writing C extensions for Python as easy as Python itself.
#
# Home page: https://cython.org/
# Download:  https://files.pythonhosted.org/packages/49/8a/6a4135469372da2e3d9f88f71c6d00d8a07ef65f121eeca0c7ae21697219/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
