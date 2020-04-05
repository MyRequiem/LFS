#! /bin/bash

PRGNAME="python2"

### Python
# Язык программирования Python

# http://www.linuxfromscratch.org/blfs/view/svn/general/python2.html

# Home page: https://www.python.org/
# Download:  https://www.python.org/ftp/python/2.7.17/Python-2.7.17.tar.xz

# Required: no
# Optional: bluez
#           valgrind
#           sqlite
#           tk

ROOT="/"
source "${ROOT}check_environment.sh"              || exit 1
source "${ROOT}unpack_source_archive.sh" "Python" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

./configure              \
    --prefix=/usr        \
    --enable-shared      \
    --with-system-expat  \
    --with-system-ffi    \
    --with-ensurepip=yes \
    --enable-unicode=ucs4 || exit 1

make || exit 1
# make -k test
make install DESTDIR="${TMP_DIR}"

(
    cd "${TMP_DIR}/usr/bin" || exit 1
    # /usr/bin/2to3 уже установлена с пакетом python3
    rm -f 2to3
    ln -svf easy_install-2.7 easy_install
    ln -svf pip2 pip
    ln -svf pip2.7 pip2
)

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
chmod -v 755 "${TMP_DIR}/usr/lib/libpython${MAJ_VERSION}.so.1.0"

# устанавливаем в корень файловой системы
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
