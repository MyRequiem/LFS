#! /bin/bash

PRGNAME="python-py"
ARCH_NAME="py"

### py (library with cross-python path)
# Библиотека поддержки разработки Python, содержащая следующие инструменты и
# модули:
#    py.path      - унифицированные локальные и svn пути объектов
#    py.apipkg    - явное управление с помощью API и ленивый импорт
#    py.iniconfig - простой анализ .ini файлов
#    py.code      - динамическая генерация кода и самоанализ

# Required:    python-setuptools-scm
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
# Package: ${PRGNAME} (library with cross-python path)
#
# The py lib is a Python development support library featuring the following
# tools and modules:
#    py.path      - uniform local and svn path objects
#    py.apipkg    - explicit API control and lazy-importing
#    py.iniconfig - easy parsing of .ini files
#    py.code      - dynamic code generation and introspection
#
# Home page: https://pypi.org/project/${ARCH_NAME}/
# Download:  https://files.pythonhosted.org/packages/98/ff/fec109ceb715d2a6b4c4a85a61af3b40c723a961e8828319fbcb15b868dc/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
