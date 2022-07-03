#! /bin/bash

PRGNAME="flake8"

### flake8 (Wrapper tool)
# Инструмент Python, который связывает вместе pep8, pyflakes, mccabe и
# сторонние плагины для проверки стиля и качества кода Python

# Required:    python-pytest
#              python-pytest-runner
#              pycodestyle
#              pyflakes
#              python-mccabe
#              python-configparser
#              python2-enum34
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# игнорируем версию setuptools
sed -i "s/setuptools >= 30\",/\"/" setup.py || exit 1

python2 setup.py build || exit 1
python2 setup.py install --optimize=1 --root="${TMP_DIR}"

python3 setup.py build || exit 1
python3 setup.py install --optimize=1 --root="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Wrapper tool)
#
# flake8 is a python tool that glues together pep8, pyflakes, mccabe, and
# third-party plugins to check the style and quality of some python code.
#
# Home page: https://pypi.org/project/${PRGNAME}/
# Download:  https://files.pythonhosted.org/packages/9e/47/15b267dfe7e03dca4c4c06e7eadbd55ef4dfd368b13a0bab36d708b14366/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
