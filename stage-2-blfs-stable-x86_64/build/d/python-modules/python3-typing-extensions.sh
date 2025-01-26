#! /bin/bash

PRGNAME="python3-typing-extensions"
ARCH_NAME="typing_extensions"

### Typing_extensions (Backported and Experimental Type Hints for Python)
# Модуль typing был добавлен в стандартную библиотеку Python 3.5 на на
# временной основе и больше не будет временным в Python 3.7 Это означает, что
# пользователи Python 3.5 - 3.6, которые не могут обновиться до Python 7, не
# будут иметь возможность использовать новые типы, добавленные в модуль typing,
# например typing.Text или typing.Coroutine

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

pip3 wheel               \
    -w dist              \
    --no-build-isolation \
    --no-deps            \
    --no-cache-dir       \
    "${PWD}" || exit 1

pip3 install            \
    --root="${TMP_DIR}" \
    --no-index          \
    --find-links=dist   \
    --no-cache-dir      \
    --no-user           \
    "${ARCH_NAME}" || exit 1

# если есть директория ${TMP_DIR}/usr/lib/pythonX.X/site-packages/bin/
# перемещаем ее в ${TMP_DIR}/usr/
PYTHON_MAJ_VER="$(python3 -V | cut -d ' ' -f 2 | cut -d . -f 1,2)"
TMP_SITE_PACKAGES="${TMP_DIR}/usr/lib/python${PYTHON_MAJ_VER}/site-packages"
[ -d "${TMP_SITE_PACKAGES}/bin" ] && \
    mv "${TMP_SITE_PACKAGES}/bin" "${TMP_DIR}/usr/"

# удаляем все скомпилированные байт-коды из ${TMP_DIR}/usr/bin/, если таковые
# имеются
PYCACHE="${TMP_DIR}/usr/bin/__pycache__"
[ -d "${PYCACHE}" ] && rm -rf "${PYCACHE}"

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
# Download:  https://files.pythonhosted.org/packages/source/t/${ARCH_NAME}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
