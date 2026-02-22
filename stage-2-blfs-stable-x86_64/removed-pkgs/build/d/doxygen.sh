#! /bin/bash

PRGNAME="doxygen"

### Doxygen (documentation genetator)
# Система генерации документации из комментариев в исходном коде для множества
# языков программирования

# Required:    cmake
#              git
# Recommended: qt6
# Optional:    graphviz
#              ghostscript
#              libxml2
#              llvm
#              texlive или install-tl-unx
#              xapian
#              javacc                       (https://javacc.github.io/javacc/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${PRGNAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 4- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}-${VERSION}"*.tar.?z* || exit 1

cd "${PRGNAME}-${VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
MAN="/usr/share/man/man1"
mkdir -pv "${TMP_DIR}${MAN}"

# исправим shebang некоторых python скриптов
grep -rl '^#!.*python$' | xargs sed -i '1s/python/&3/' || exit 1

mkdir build
cd build || exit 1

cmake                            \
    -G "Unix Makefiles"          \
    -D CMAKE_BUILD_TYPE=Release  \
    -D CMAKE_INSTALL_PREFIX=/usr \
    -D build_wizard=ON           \
    -D force_qt=Qt6              \
    -D force_qt6=ON              \
    use_libclang=ON              \
    -W no-dev                    \
    .. || exit 1

make || exit 1
# make tests
make install DESTDIR="${TMP_DIR}"

install -vm644 ../doc/*.1 "${TMP_DIR}${MAN}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (documentation genetator)
#
# The Doxygen package contains a documentation system for C++, C, Java,
# Objective-C, Corba IDL and to some extent PHP, C# and D. It is useful for
# generating HTML documentation and/or an off-line reference manual from a set
# of documented source files. There is also support for generating output in
# RTF, PostScript, hyperlinked PDF, compressed HTML, and Unix man pages. The
# documentation is extracted directly from the sources, which makes it much
# easier to keep the documentation consistent with the source code.
#
# Home page: https://${PRGNAME}.nl/
# Download:  https://${PRGNAME}.nl/files/${PRGNAME}-${VERSION}.src.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
