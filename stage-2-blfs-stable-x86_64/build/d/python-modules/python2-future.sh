#! /bin/bash

PRGNAME="python2-future"
ARCH_NAME="future"

### python2-future (Python 2/3 compatibility)
# Слой совместимости между Python 2 и Python 3. Позволяет использовать чистый,
# совместимый с Python 3.x код для поддержки как Python 2, так и Python 3 с
# минимальными накладными расходами.

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

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Python 2/3 compatibility)
#
# python-future is the missing compatibility layer between Python 2 and Python
# 3. It allows you to use a single, clean Python 3.x-compatible codebase to
# support both Python 2 and Python 3 with minimal overhead.
#
# Home page: https://python-future.org/
# Download:  https://files.pythonhosted.org/packages/45/0b/38b06fd9b92dc2b68d58b75f900e97884c45bedd2ff83203d933cf5851c9/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
