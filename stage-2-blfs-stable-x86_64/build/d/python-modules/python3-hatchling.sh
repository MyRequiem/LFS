#! /bin/bash

PRGNAME="python3-hatchling"
ARCH_NAME="hatchling"

### Hatchling (Hatch build backend)
# расширяемый, совместимый со стандартами сервер сборки, используемый Hatch

# Required:    python3-build
#              python3-editables
#              python3-packaging
#              python3-pathspec
#              python3-pluggy
# Recommended: no
# Optional:    no

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
# Package: ${PRGNAME} (Hatch build backend)
#
# This is the extensible, standards compliant build backend used by Hatch
#
# Home page: https://pypi.org/project/${ARCH_NAME}/
# Download:  https://files.pythonhosted.org/packages/source/h/${ARCH_NAME}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
