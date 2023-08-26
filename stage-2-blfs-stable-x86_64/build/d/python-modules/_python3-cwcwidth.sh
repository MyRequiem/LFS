#! /bin/bash

PRGNAME="python3-cwcwidth"
ARCH_NAME="cwcwidth"

### cwcwidth (Python bindings for wcwidth and wcswidth)
# Python bindings для функций wcwidth и wcswidth, определенных в POSIX.1-2001 и
# POSIX.1-2008 на основе Cython. Эти функции вычисляют печатную длину символов
# Unicode. Работает как wcwidth и их поведение совместимо.

# Required:    python3
# Recommended: cython
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

python3 setup.py build || exit 1
python3 setup.py install --optimize=1 --root="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Python bindings for wcwidth and wcswidth)
#
# cwcwidth provides Python bindings for wcwidth and wcswidth functions defined
# in POSIX.1-2001 and POSIX.1-2008 based on Cython. These functions compute the
# printable length of a unicode characters The module provides the same
# functions as wcwidth and its behavior is compatible.
#
# Home page: https://pypi.org/project/${ARCH_NAME}/
# Download:  https://files.pythonhosted.org/packages/f4/1f/87c2615db91df199419946df2652ba3490005c80acf1ed29e52aec20d3b2/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
