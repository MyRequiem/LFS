#! /bin/bash

PRGNAME="python3-pytest"
ARCH_NAME="pytest"

### Pytest (simple powerful testing with Python)
# Полнофункциональный инструмент для тестирования Python программ.

# Required:    python3-attrs
#              python3-iniconfig
#              python3-packaging
#              python3-pluggy
#              python3-py
# Recommended: python3-setuptools-scm
# Optional:    --- для тестов ---
#              python3-pygments
#              python3-requests
#              python3-argcomplete (https://pypi.org/project/argcomplete/)
#              python3-hypothesis  (https://pypi.org/project/hypothesis/)
#              python3-mock        (https://pypi.org/project/mock/)
#              python3-nose        (https://pypi.org/project/nose/)
#              python3-xmlschema   (https://pypi.org/project/xmlschema/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# сборка с помощью модуля build (пакет python3-build) и установка с помощью
# модуля installer (пакет python3-installer)
python3 -m build --no-isolation                       || exit 1
python3 -m installer -d "${TMP_DIR}" \
    ./dist/"${ARCH_NAME}-${VERSION}-py3-none-any.whl" || exit 1

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (simple powerful testing with Python)
#
# A mature full-featured Python testing tool. Helps you write better programs.
#
# Home page: https://pypi.org/project/${ARCH_NAME}/
# Download:  https://files.pythonhosted.org/packages/source/p/${ARCH_NAME}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
