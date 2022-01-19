#! /bin/bash

PRGNAME="python-pycryptodome"
ARCH_NAME="pycryptodome"

### python3-pycryptodome (Python Cryptography Toolkit)
# Набор безопасных хэш-функций (таких как SHA256 и RIPEMD160) и различные
# алгоритмы шифрования (AES, DES, RSA, ElGamal и др.). Является форком PyCrypto

# Required:    no
# Recommended: no
# Optional:    no

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
# Package: ${PRGNAME} (Python Cryptography Toolkit)
#
# PyCryptodome is a collection of both secure hash functions (such as SHA256
# and RIPEMD160), and various encryption algorithms (AES, DES, RSA, ElGamal,
# etc.). PyCryptodome is a fork of PyCrypto. It's a self-contained Python
# package of low-level cryptographic primitives. It supports Python 2.6 or
# newer, all Python 3 versions and PyPy. PyCryptodome is not a wrapper to a
# separate C library like OpenSSL. To the largest possible extent, algorithms
# are implemented in pure Python. Only the pieces that are extremely critical
# to performance (e.g. block ciphers) are implemented as C extensions.
#
# Home page: https://pypi.org/project/${ARCH_NAME}/
# Download:  https://github.com/Legrandin/${ARCH_NAME}/archive/v${VERSION}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
