#! /bin/bash

PRGNAME="python-six"
ARCH_NAME="six"

### python-six
# Python библиотека совместимая Python2 и Python3. Обеспечивает функции
# сглаживания различий между версиями Python с целью написания кода,
# совместимого с Python2 и Python3

# http://www.linuxfromscratch.org/blfs/view/9.0/general/python-modules.html#six

# Home page: https://pypi.python.org/pypi/six/
# Download:  https://pypi.io/packages/source/s/six/six-1.12.0.tar.gz

# Required: python2
#           python3
# Optional: no

ROOT="/"
source "${ROOT}check_environment.sh"                    || exit 1
source "${ROOT}unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

python2 setup.py build || exit 1
python3 setup.py build || exit 1

# пакет не имеет набора тестов, сразу устанавливаем
python2 setup.py install --optimize=1 --root="${TMP_DIR}"
python3 setup.py install --optimize=1 --root="${TMP_DIR}"
cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Python2 and Python3 compatibility utilities)
#
# Six is a Python 2 and 3 compatibility library. It provides utility functions
# for smoothing over the differences between the Python versions with the goal
# of writing Python code that is compatible on both Python versions. See the
# documentation for more information on what is provided.
#
# Home page: https://pypi.python.org/pypi/${ARCH_NAME}/
# Download:  https://pypi.io/packages/source/s/${ARCH_NAME}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
