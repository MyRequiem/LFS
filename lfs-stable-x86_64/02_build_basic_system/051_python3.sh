#! /bin/bash

PRGNAME="python3"

### python3
# Язык программирования Python 3

# http://www.linuxfromscratch.org/lfs/view/stable/chapter06/Python.html

# Home page: https://www.python.org/
# Download:  https://www.python.org/ftp/python/3.8.1/Python-3.8.1.tar.xz
# Docs:      https://www.python.org/ftp/python/doc/3.8.1/python-3.8.1-docs-html.tar.bz2

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
# создавать программы pip и setuptools
#    --with-ensurepip=yes
./configure             \
    --prefix=/usr       \
    --enable-shared     \
    --with-system-expat \
    --with-system-ffi   \
    --with-ensurepip=yes || exit 1

make || exit 1

# тесты на данном этапе не запускаем, т.к. они требуют установленных TK и
# X Window System, поэтому сразу устанавливаем в корневую систему

# Важно: сначала устанавливаем во временную директорию и только потом в корень
# системы
make install DESTDIR="${TMP_DIR}"
make install

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
chmod -v 755 "/usr/lib/libpython${MAJ_VERSION}.so"
chmod -v 755 /usr/lib/libpython3.so
chmod -v 755 "${TMP_DIR}/usr/lib/libpython${MAJ_VERSION}.so"
chmod -v 755 "${TMP_DIR}/usr/lib/libpython3.so"

# ссылка в /usr/bin
# pip3 -> pip${MAJ_VERSION}
ln -svf "pip${MAJ_VERSION}" /usr/bin/pip3
(
    cd "${TMP_DIR}/usr/bin" || exit 1
    ln -sfv "pip${MAJ_VERSION}" pip3
)

# устанавливаем документацию
PYTHON_DOC_ARCH_NAME="python-${VERSION}-docs-html"
tar xvf "/sources/${PYTHON_DOC_ARCH_NAME}".tar.?z* || exit 1
cd "${PYTHON_DOC_ARCH_NAME}" || exit 1
chown -R root:root ./*

DOCS="/usr/share/doc/python-${VERSION}/html"
install -v -dm755 "${DOCS}"
cp -R ./*         "${DOCS}"

install -v -dm755 "${TMP_DIR}/${DOCS}"
cp -R ./*         "${TMP_DIR}/${DOCS}"

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
