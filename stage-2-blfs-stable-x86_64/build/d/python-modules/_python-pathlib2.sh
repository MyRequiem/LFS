#! /bin/bash

PRGNAME="python-pathlib2"
ARCH_NAME="pathlib2"

### pathlib2 (Object-oriented filesystem paths)
# Старый модуль pathlib на bitbucket находится в режиме исправления ошибок.
# pathlib2 должен предоставить резервную копию стандартного модуля pathlib,
# который отслеживает стандартный библиотечный модуль, поэтому все новейшие
# функции стандартной библиотеки pathlib можно использовать и в более старых
# версиях Python.

# Required:    python2
#              python3
#              python3-six
#              python-scandir
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
# Package: ${PRGNAME} (Object-oriented filesystem paths)
#
# The old pathlib module on bitbucket is in bugfix-only mode. The goal of
# pathlib2 is to provide a backport of standard pathlib module which tracks the
# standard library module, so all the newest features of the standard pathlib
# can be used also on older Python versions.
#
# Home page: https://pypi.org/project/${ARCH_NAME}/
# Download:  https://files.pythonhosted.org/packages/df/16/e9d6bcf1aed52a55bc1696324ab22586716053b3e97b85266e0f3ad36bae/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
