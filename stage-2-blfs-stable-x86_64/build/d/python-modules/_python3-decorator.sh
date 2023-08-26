#! /bin/bash

PRGNAME="python3-decorator"
ARCH_NAME="decorator"

### python3-decorator (decorator module for Python)
# Упрощение использования декораторов в Python

# Required:    python3
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

python3 setup.py build || exit 1
# пакет не имеет набора тестов
python3 setup.py install --optimize=1 --root="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (decorator module for Python)
#
# The aim of the decorator module it to simplify the usage of decorators for
# the average programmer, and to popularize decorators usage giving examples of
# useful decorators, such as memoize, tracing, redirecting_stdout, locked, etc.
#
# Home page: https://pypi.python.org/pypi/${ARCH_NAME}
# Download:  https://files.pythonhosted.org/packages/source/d/${ARCH_NAME}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
