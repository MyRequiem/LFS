#! /bin/bash

PRGNAME="python3-pyproject-metadata"
ARCH_NAME="pyproject-metadata"

### Pyproject-Metadata (Dataclass for PEP 621 metadata)
# модуль проверяет входные данные и генерирует файл метаданных, совместимый с
# PEP 643 (например, PKG-INFO)

# Required:    python3-packaging
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# сборка с помощью модуля build (пакет python3-build) и установка с помощью
# модуля installer (пакет python3-installer)
python3 -m build --no-isolation                             || exit 1
python3 -m installer -d "${TMP_DIR}" \
    ./dist/"pyproject_metadata-${VERSION}-py3-none-any.whl" || exit 1

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Dataclass for PEP 621 metadata)
#
# given a Python data structure representing PEP 621 metadata (already parsed),
# it will validate this input and generate a PEP 643-compliant metadata file
# (e.g. PKG-INFO)
#
# Home page: https://pypi.org/project/${ARCH_NAME}/
# Download:  https://files.pythonhosted.org/packages/source/p/${ARCH_NAME}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
