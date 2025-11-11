#! /bin/bash

PRGNAME="python3-urllib3"
ARCH_NAME="urllib3"

### Urllib3 (Powerful, sanity-friendly HTTP client for Python)
# Мощный и удобный HTTP-клиент для Python

# Required:    python3-hatch-vcs
# Recommended: no
# Optional:    --- для тестов ---
#              python3-pytest
#              python3-httpx             (https://pypi.org/project/httpx/)
#              python3-hypercorn         (https://pypi.org/project/Hypercorn/)
#              python3-mock              (https://pypi.org/project/mock/)
#              python3-pysocks           (https://pypi.org/project/PySocks/)
#              python3-pytest-timeout    (https://pypi.org/project/pytest-timeout/)
#              python3-dateutil          (https://pypi.org/project/python-dateutil/)
#              python3-quart             (https://pypi.org/project/Quart/)
#              python3-quart-trio        (https://pypi.org/project/quart-trio/)
#              python3-tornado           (https://pypi.org/project/tornado/)
#              python3-trio              (https://pypi.org/project/trio/)
#              python3-trustme           (https://pypi.org/project/trustme/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

pip3 wheel               \
    -w dist              \
    --no-build-isolation \
    --no-deps            \
    --no-cache-dir       \
    "${PWD}" || exit 1

pip3 install            \
    --root="${TMP_DIR}" \
    --no-index          \
    --find-links dist   \
    --no-user           \
    "${ARCH_NAME}" || exit 1

# если есть директория ${TMP_DIR}/usr/lib/pythonX.X/site-packages/bin/
# перемещаем ее в ${TMP_DIR}/usr/
PYTHON_MAJ_VER="$(python3 -V | cut -d ' ' -f 2 | cut -d . -f 1,2)"
TMP_SITE_PACKAGES="${TMP_DIR}/usr/lib/python${PYTHON_MAJ_VER}/site-packages"
[ -d "${TMP_SITE_PACKAGES}/bin" ] && \
    mv "${TMP_SITE_PACKAGES}/bin" "${TMP_DIR}/usr/"

# удаляем все скомпилированные байт-коды из ${TMP_DIR}/usr/bin/, если таковые
# имеются
PYCACHE="${TMP_DIR}/usr/bin/__pycache__"
[ -d "${PYCACHE}" ] && rm -rf "${PYCACHE}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Powerful, sanity-friendly HTTP client for Python)
#
# Urllib3 is a powerful, sanity-friendly HTTP client for Python. Much of the
# Python ecosystem already uses Urllib3 and you should too.
#
# Home page: https://pypi.org/project/${ARCH_NAME}/
# Download:  https://files.pythonhosted.org/packages/source/u/${ARCH_NAME}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
