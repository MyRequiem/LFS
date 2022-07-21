#! /bin/bash

PRGNAME="pylint3"
ARCH_NAME="pylint"

### pylint3 (python code checker)
# Инструмент статического анализа кода для Python 3

# Required:    python3
#              python-pytest-runner
#              python3-typed-ast
#              python-toml
#              python-astroid
#              isort
#              python-mccabe
#              python-appdirs
#              python-configparser
#              python-pies
#              python-functools-lru-cache
#              python-singledispatch
#              python-dill
#              python3-platformdirs
#              python-tomlkit
#              python-tomli
#              python-typing-extensions
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${ARCH_NAME}-2*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${ARCH_NAME}-${VERSION}"*.tar.?z* || exit 1
cd "${ARCH_NAME}-${VERSION}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

python3 setup.py build || exit 1
python3 setup.py install --optimize=1 --root="${TMP_DIR}"

# не конфликтуем с пакетом pylint2, переименовываем утилиты и создаем ссылки
(
    cd "${TMP_DIR}/usr/bin" || exit 1

    mv e${ARCH_NAME}       e${ARCH_NAME}3
    mv ${ARCH_NAME}        ${ARCH_NAME}3
    mv ${ARCH_NAME}-config ${ARCH_NAME}-config3
    mv pyreverse           pyreverse3
    mv symilar             symilar3

    ln -s e${ARCH_NAME}3       e${ARCH_NAME}
    ln -s ${ARCH_NAME}3        ${ARCH_NAME}
    ln -s ${ARCH_NAME}-config3 ${ARCH_NAME}-config
    ln -s pyreverse3           pyreverse
    ln -s symilar3             symilar
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
# Download:  https://files.pythonhosted.org/packages/82/e5/ae649803c4f3a4e47720337352af046089f8e9ff8a25958199df74268984/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
