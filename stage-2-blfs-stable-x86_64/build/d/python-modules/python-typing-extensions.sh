#! /bin/bash

PRGNAME="python-typing-extensions"
ARCH_NAME="typing_extensions"

### typing-extensions (Backported and Experimental Type Hints for Python)
# Модуль typing был добавлен в стандартную библиотеку Python 3.5 на на
# временной основе и больше не будет временным в Python 3.7 Это означает, что
# пользователи Python 3.5 - 3.6, которые не могут обновиться до Python 7, не
# будут иметь возможность использовать новые типы, добавленные в модуль typing,
# например typing.Text или typing.Coroutine

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
# Package: ${PRGNAME} (Backported and Experimental Type Hints for Python)
#
# The typing module was added to the standard library in Python 3.5 on a
# provisional basis and will no longer be provisional in Python 3.7. However,
# this means users of Python 3.5 - 3.6 who are unable to upgrade willnot be
# able to take advantage of new types added to the typing module, such as
# typing.Text or typing.Coroutine
#
# Home page: https://pypi.org/project/typing-extensions/
# Download:  https://files.pythonhosted.org/packages/ed/12/c5079a15cf5c01d7f4252b473b00f7e68ee711be605b9f001528f0298b98/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
