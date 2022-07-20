#! /bin/bash

PRGNAME="python-functools-lru-cache"
ARCH_NAME="backports.functools_lru_cache"

### backports.functools_lru_cache (backport of functools.lru_cache)
# Бэкпорт functools.lru_cache из Python 3.3

# Required:    python2
#              python3
#              python-setuptools-scm
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
# Package: ${PRGNAME} (backport of functools.lru_cache)
#
# This is a backport of functools.lru_cache from Python 3.3 as published at
# ActiveState
#
# Home page: https://pypi.org/project/backports.functools-lru-cache/
# Download:  https://files.pythonhosted.org/packages/95/9f/122a41912932c77d5b8e6cab6bd456e6270211a3ed7248a80c235179a012/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
