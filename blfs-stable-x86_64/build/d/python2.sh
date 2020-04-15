#! /bin/bash

PRGNAME="python2"

### Python
# Язык программирования Python

# http://www.linuxfromscratch.org/blfs/view/stable/general/python2.html

# Home page: https://www.python.org/
# Download:  https://www.python.org/ftp/python/2.7.17/Python-2.7.17.tar.xz
# Docs:      https://docs.python.org/ftp/python/doc/2.7.17/python-2.7.17-docs-html.tar.bz2

# Required: no
# Optional: bluez
#           valgrind
#           sqlite   (для создания дополнительных модулей)
#           tk       (для создания дополнительных модулей)

ROOT="/root"
source "${ROOT}/check_environment.sh"              || exit 1

INSTALLED="$(find /var/log/packages/ -type f -name "python2-2.*")"
if [ -n "${INSTALLED}" ]; then
    INSTALLED_VERSION="$(echo "${INSTALLED}" | rev | cut -d / -f 1 | rev)"
    echo "${INSTALLED_VERSION} already installed. Before building Python2 "
    echo "package, you need to remove it."
    removepkg --no-color "${INSTALLED}"
fi

source "${ROOT}/unpack_source_archive.sh" "Python" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
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

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
(
    cd "${TMP_DIR}/usr/bin" || exit 1
    # /usr/bin/2to3 уже установлена с пакетом python3
    rm -f 2to3
    ln -svf "easy_install-${MAJ_VERSION}" easy_install
    ln -svf pip2 pip
    ln -svf "pip${MAJ_VERSION}" pip2
)

chmod -v 755 "${TMP_DIR}/usr/lib/libpython${MAJ_VERSION}.so.1.0"

# документация
DOCS="${TMP_DIR}/usr/share/doc/${PRGNAME}-${VERSION}"
install -v -dm755 "${DOCS}"

tar                       \
    --strip-components=1  \
    --no-same-owner       \
    --directory "${DOCS}" \
    -xvf "${SOURCES}/python-${VERSION}-docs-html.tar.bz2"

find "${DOCS}" -type d -exec chmod 0755 {} \;
find "${DOCS}" -type f -exec chmod 0644 {} \;

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
