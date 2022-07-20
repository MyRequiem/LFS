#! /bin/bash

PRGNAME="isort"

### isort (sort imports alphabetically)
# Сортировка импорта Python модулей в алфавитном порядке и автоматическое
# разделения на разделы

# Required:    python2
#              python3
#              python-pies
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

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
# Package: ${PRGNAME} (sort imports alphabetically)
#
# isort is a Python utility/library to sort imports alphabetically, and
# automatically separated into sections. It provides a command line utility,
# Python library and plugins for various editors to quickly sort all your
# imports.
#
# Home page: https://pypi.org/project/${PRGNAME}/
# Download:  https://files.pythonhosted.org/packages/ab/e9/964cb0b2eedd80c92f5172f1f8ae0443781a9d461c1372a3ce5762489593/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
