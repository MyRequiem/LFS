#! /bin/bash

PRGNAME="python-tomlkit"
ARCH_NAME="tomlkit"

### tomlkit (style preserving TOML library)
# TOML Kit - библиотека TOML для Python, сохраняющая стили. Сохраняет все
# комментарии, отступы, пробелы, внутренние элементы и делает их доступными и
# редактируемыми через интуитивно понятный API

# Required:    python2
#              python3
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

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
# Package: ${PRGNAME} (style preserving TOML library)
#
# TOML Kit - Style-preserving TOML library for Python It includes a parser that
# preserves all comments, indentations, whitespace and internal element
# ordering, and makes them accessible and editable via an intuitive API
#
# Home page: https://pypi.org/project/${ARCH_NAME}/
# Download:  https://files.pythonhosted.org/packages/1e/81/93889ea6641154b22f26036bc4ef800b06df84fc647a6ded5abdc2f06dcf/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
