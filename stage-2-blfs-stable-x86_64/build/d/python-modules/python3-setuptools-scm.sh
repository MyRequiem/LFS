#! /bin/bash

PRGNAME="python3-setuptools-scm"
ARCH_NAME="setuptools_scm"

### Setuptools_scm (manage versions by scm tags)
# Управляет версиями пакетов python в метаданных scm вместо того, чтобы
# объявлять их в качестве аргумента версии или в файле, управляемом scm. Также
# обрабатывает средства поиска файлов поддерживаемых scms

# Required:    python3-build
#              python3-packaging
#              python3-typing-extensions
# Recommended: no
# Optional:    --- для тестов ---
#              git
#              mercurial
#              python3-pytest

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
# Package: ${PRGNAME} (manage versions by scm tags)
#
# setuptools_scm handles managing your python package versions in scm metadata
# instead of declaring them as the version argument or in a scm managed file.
# It also handles file finders for the supported scms.
#
# Home page: https://pypi.org/project/${ARCH_NAME}/
# Download:  https://files.pythonhosted.org/packages/source/s/${ARCH_NAME}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
