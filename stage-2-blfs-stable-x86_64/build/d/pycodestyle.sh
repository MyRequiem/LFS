#! /bin/bash

PRGNAME="pycodestyle"

### pycodestyle (Python style guide checker)
# Инструмент для проверки кода Python на соответствие некоторым стилям и
# соглашениям PEP 8

# Required:    python2
#              python3
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
# Package: ${PRGNAME} (Python style guide checker)
#
# pycodestyle is a tool to check your Python code against some of the style
# conventions in PEP 8.
#
# Home page: https://${PRGNAME}.readthedocs.io/en/latest/
# Download:  https://files.pythonhosted.org/packages/08/dc/b29daf0a202b03f57c19e7295b60d1d5e1281c45a6f5f573e41830819918/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
