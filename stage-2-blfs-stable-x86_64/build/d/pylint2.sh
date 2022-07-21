#! /bin/bash

PRGNAME="pylint2"
ARCH_NAME="pylint"

### pylint2 (python code checker)
# Инструмент статического анализа кода для Python 2

# Required:    python2
#              python2-astroid
#              isort
#              python-functools-lru-cache
#              python-configparser
#              python-singledispatch
#              python-mccabe
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${ARCH_NAME}-1*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${ARCH_NAME}-${VERSION}"*.tar.?z* || exit 1
cd "${ARCH_NAME}-${VERSION}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

python2 setup.py build || exit 1
python2 setup.py install --optimize=1 --root="${TMP_DIR}"

# не конфликтуем с пакетом pylint3, переименовываем утилиты
(
    cd "${TMP_DIR}/usr/bin" || exit 1

    mv e${ARCH_NAME}       e${ARCH_NAME}2
    mv ${ARCH_NAME}        ${ARCH_NAME}2
    mv pyreverse           pyreverse2
    mv symilar             symilar2
)

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (python code checker)
#
# Pylint is a python tool that checks if a module satisfies a coding standard.
# Pylint can be seen as another PyChecker since nearly all tests you can do
# with PyChecker can also be done with Pylint. But Pylint offers some more
# features. The big advantage with Pylint is that it is highly configurable,
# customizable, and you can easily write a small plugin to add a personal
# feature.
#
# Home page: https://pypi.org/project/${ARCH_NAME}/
# Download:  https://files.pythonhosted.org/packages/3f/0b/4e7eeab1abf594b447385a340593c1a4244cdf8e54a78edcae1e2756d6fb/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
