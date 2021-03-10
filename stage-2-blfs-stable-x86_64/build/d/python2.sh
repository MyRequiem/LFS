#! /bin/bash

PRGNAME="python2"
ARCH_NAME="Python"

### Python (object-oriented interpreted programming language)
# Язык программирования Python

# Required:    no
# Recommended: no
# Optional:    bluez
#              valgrind
#              sqlite   (для создания дополнительных модулей)
#              tk       (для создания дополнительных модулей)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

INSTALLED="$(find /var/log/packages/ -type f -name "python2-2.*")"
if [ -n "${INSTALLED}" ]; then
    INSTALLED_VERSION="$(echo "${INSTALLED}" | rev | cut -d / -f 1 | rev)"
    echo "${INSTALLED_VERSION} already installed. Before building Python2 "
    echo "package, you need to remove it."
    removepkg --no-color "${INSTALLED}"
fi

SOURCES="${ROOT}/src"
VERSION="$(find ${SOURCES} -type f \
    -name "${ARCH_NAME}-2*.tar.?z*" 2>/dev/null | sort | \
    head -n 1 | rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1
tar xvf "${SOURCES}/Python-${VERSION}".tar.?z* || exit 1
cd "${ARCH_NAME}-${VERSION}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# отключим установку утилиты 2to3
sed -i '/2to3/d' ./setup.py

VALGRIND="--without-valgrind"
command -v valgrind &>/dev/null && VALGRIND="--with-valgrind"

./configure              \
    --prefix=/usr        \
    --enable-shared      \
    --with-system-expat  \
    --with-system-ffi    \
    "${VALGRIND}"        \
    --enable-unicode=ucs4 || exit 1

make || exit 1
# make -k test
make altinstall DESTDIR="${TMP_DIR}"

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
(
    cd "${TMP_DIR}/usr/bin" || exit 1
    # /usr/bin/2to3 уже установлена с пакетом python3
    rm -f 2to3
    ln -svf python2.7 python2
    ln -svf python2.7-config python2-config
)

chmod -v 755 "${TMP_DIR}/usr/lib/libpython${MAJ_VERSION}.so.1.0"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

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
