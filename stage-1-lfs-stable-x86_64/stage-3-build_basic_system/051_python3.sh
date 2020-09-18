#! /bin/bash

PRGNAME="python3"

### python3 (object-oriented interpreted programming language)
# Язык программирования Python 3

# http://www.linuxfromscratch.org/lfs/view/stable/chapter06/Python.html

# Home page: https://www.python.org/
# Download:  https://www.python.org/ftp/python/3.8.3/Python-3.8.3.tar.xz
# Docs:      https://www.python.org/ftp/python/doc/3.8.3/python-3.8.3-docs-html.tar.bz2

ROOT="/"
source "${ROOT}check_environment.sh"              || exit 1
source "${ROOT}unpack_source_archive.sh" "Python" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# связываться с уже установленной системной версией Expat
#    --with-system-expat
# связываться с уже установленной системной версией libffi
#    --with-system-ffi
# создавать утилиты pip и setuptools
#    --with-ensurepip=yes
./configure             \
    --prefix=/usr       \
    --enable-shared     \
    --with-system-expat \
    --with-system-ffi   \
    --with-ensurepip=yes || exit 1

make || exit 1

# тесты на данном этапе не запускаем, т.к. они требуют установленных TK и
# X Window System, поэтому сразу устанавливаем
make install DESTDIR="${TMP_DIR}"

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
chmod -v 755 "${TMP_DIR}/usr/lib/libpython${MAJ_VERSION}.so"
chmod -v 755 "${TMP_DIR}/usr/lib/libpython3.so"

# ссылки в /usr/bin
# pip3          -> pip${MAJ_VERSION}
# easy_install3 -> easy_install-${MAJ_VERSION}
(
    cd "${TMP_DIR}/usr/bin" || exit 1
    ln -sfv "pip${MAJ_VERSION}" pip3
    ln -sfv "easy_install-${MAJ_VERSION}" easy_install3
)

# устанавливаем документацию
DOCS="${TMP_DIR}/usr/share/doc/${PRGNAME}-${VERSION}/html"
install -v -dm755 "${DOCS}"
tar                       \
    --strip-components=1  \
    --no-same-owner       \
    --no-same-permissions \
    -C "${DOCS}"          \
    -xvf "/sources/python-${VERSION}-docs-html.tar.bz2"

# устанавливаем пакет в корень файловой системы
cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (object-oriented interpreted programming language)
#
# Python is an interpreted, interactive, object-oriented programming language
# that combines remarkable power with very clear syntax. Python's basic power
# can be extended with your own modules written in C or C++. Python is also
# adaptable as an extension language for existing applications.
#
# Home page: https://www.python.org/
# Download:  https://www.python.org/ftp/python/${VERSION}/Python-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
