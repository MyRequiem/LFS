#! /bin/bash

PRGNAME="python3"
ARCH_NAME="Python"

### python3 (object-oriented interpreted programming language)
# Язык программирования Python 3

ROOT="/"
source "${ROOT}check_environment.sh"                    || exit 1
source "${ROOT}unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

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

make || make -j1 || exit 1

# тесты на данном этапе не запускаем, т.к. они требуют сконфигурированного
# сетевого подключения и установленных TK и X Window System

make install DESTDIR="${TMP_DIR}"

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
chmod -v 755 "${TMP_DIR}/usr/lib/libpython${MAJ_VERSION}.so"
chmod -v 755 "${TMP_DIR}/usr/lib/libpython3.so"

# ссылки в /usr/bin
# pip3          -> pip${MAJ_VERSION}
# easy_install3 -> easy_install-${MAJ_VERSION}
ln -sfv "pip${MAJ_VERSION}"           "${TMP_DIR}/usr/bin/pip3"
ln -sfv "easy_install-${MAJ_VERSION}" "${TMP_DIR}/usr/bin/easy_install3"

# устанавливаем документацию
DOCS="${TMP_DIR}/usr/share/doc/${PRGNAME}-${VERSION}/html"
install -v -dm755 "${DOCS}"
tar                       \
    --strip-components=1  \
    --no-same-owner       \
    --no-same-permissions \
    -C "${DOCS}"          \
    -xvf "${SOURCES}/python-${VERSION}-docs-html.tar.bz2"

# устанавливаем пакет в корень файловой системы
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
