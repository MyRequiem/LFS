#! /bin/bash

PRGNAME="python3-pylint"
ARCH_NAME="pylint"

### pylint3 (python code checker)
# Инструмент статического анализа кода для Python 3

# Required:    python3-platformdirs
#              python3-astroid
#              python3-isort
#              python3-mccabe
#              python3-tomlkit
#              python3-typing-extensions
#              python3-dill
#              python3-tomli
#              python3-flit-core
#              python3-installer
#              python-zipp
#              python3-pyproject-hooks
#              python3-importlib-metadata
#              python3-build
#              python3-calver
#              python3-editables
#              python3-pathspec
#              python3-pluggy
#              python3-trove-classifiers
#              python3-hatchling
#              python3-hatch-vcs
#              python3-poetry-core
#              python3-lazy-object-proxy
#              python3-wrapt
#              -----
#              ???
#              -----
#              python-pytest-runner
#              python3-typed-ast
#              python-toml
#              python3-appdirs
#              python-configparser
#              python-pies
#              python-functools-lru-cache
#              python-singledispatch
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
