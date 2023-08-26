#! /bin/bash

PRGNAME="python-urwid"
ARCH_NAME="urwid"

### python-urwid (python console UI module)
# Python библиотека консольного пользовательского интерфейса. Включает в себя
# много полезных функций для разработчиков текстовых консольных приложений.

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
# Package: ${PRGNAME} (python console UI module)
#
# Urwid is a console user interface library for Python. It is released under
# the GNU Lesser General Public License and includes many (too many to list)
# features useful for text console application developers.
#
# Home page: http://${ARCH_NAME}.org
# Download:  https://pypi.org/packages/source/u/${ARCH_NAME}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
