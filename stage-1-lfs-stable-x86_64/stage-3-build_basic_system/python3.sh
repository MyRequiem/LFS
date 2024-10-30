#! /bin/bash

PRGNAME="python3"
ARCH_NAME="Python"

### python3 (object-oriented interpreted programming language)
# Python 3 интерпретатор

ROOT="/"
source "${ROOT}check_environment.sh"                    || exit 1
source "${ROOT}unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/etc"

# связываться с уже установленной системной версией Expat
#    --with-system-expat
# связываться с уже установленной системной версией libffi
#    --with-system-ffi
./configure             \
    --prefix=/usr       \
    --enable-shared     \
    --with-system-expat \
    --with-system-ffi   \
    --enable-optimizations || exit 1

make || make -j1 || exit 1

# тесты на данном этапе не запускаем, т.к. они требуют сконфигурированного
# сетевого подключения и установленных TK и Graphical Environments
# make test

make install DESTDIR="${TMP_DIR}"

cat << EOF > "${TMP_DIR}/etc/pip.conf"
[global]
root-user-action = ignore
disable-pip-version-check = true
EOF

# ссылка в /usr/bin
#    pip3 -> pip${MAJ_VERSION}
MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
ln -sfv "pip${MAJ_VERSION}" "${TMP_DIR}/usr/bin/pip3"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (object-oriented interpreted programming language)
#
# Python is an interpreted, interactive, object-oriented programming language
# that combines remarkable power with very clear syntax. Python's basic power
# can be extended with your own modules written in C or C++. Python is also
# adaptable as an extension language for existing applications.
#
# Home page: https://www.python.org/
# Download:  https://www.python.org/ftp/python/${VERSION}/${ARCH_NAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
