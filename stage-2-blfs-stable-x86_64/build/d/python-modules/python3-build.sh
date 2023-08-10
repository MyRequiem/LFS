#! /bin/bash

PRGNAME="python3-build"
ARCH_NAME="build"

### Build (A simple, correct Python build frontend)
# инструмент для сборки Python пакетов в соответствии с PEP517 спецификацией

# Required:    python3-flit-core
#              python3-installer
#              python3-pyproject-hooks
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

python3 -m flit_core.wheel                            || exit 1
python3 -m installer -d "${TMP_DIR}" \
    ./dist/"${ARCH_NAME}-${VERSION}-py3-none-any.whl" || exit 1

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (A simple, correct Python build frontend)
#
# A simple, correct PEP517 Python build frontend
#
# Home page: https://pypi.org/project/${ARCH_NAME}/
# Download:  https://files.pythonhosted.org/packages/source/b/${ARCH_NAME}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
