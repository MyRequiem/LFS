#! /bin/bash

PRGNAME="python3-hatch-vcs"
URL_NAME="hatch-vcs"
ARCH_NAME="hatch_vcs"

### Hatch_vcs (Hatch plugin for versioning with preferred VCS)
# предоставляет подключаемый модуль для Hatch, который использует
# предпочитаемую вами систему контроля вверсий (Git, Mercurial) для определения
# версии проекта

# Required:    python3-build
#              python3-hatchling
#              python3-setuptools-scm
# Recommended: no
# Optional:    python3-pytest

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

python3 -m build --no-isolation                       || exit 1
python3 -m installer -d "${TMP_DIR}" \
    ./dist/"${ARCH_NAME}-${VERSION}-py3-none-any.whl" || exit 1

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Hatch plugin for versioning with preferred VCS)
#
# This provides a plugin for Hatch that uses your preferred version control
# system (like Git) to determine project versions.
#
# Home page: https://pypi.org/project/${URL_NAME}/
# Download:  https://files.pythonhosted.org/packages/source/h/${URL_NAME}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
