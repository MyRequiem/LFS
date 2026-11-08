#! /bin/bash

PRGNAME="fltk"

### FLTK (The Fast Light Tool Kit)
# Невероятно компактная библиотека для создания оконных интерфейсов, которая
# практически не потребляет системных ресурсов. Идеально подходит для маленьких
# утилит, где важна скорость работы и малый размер.

# Required:    xorg-libraries
# Recommended: hicolor-icon-theme
#              libjpeg-turbo
#              libpng
# Optional:    alsa-lib
#              desktop-file-utils
#              mesa

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${PRGNAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 2 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}-${VERSION}-source"*.tar.?z* || exit 1
cd "${PRGNAME}-${VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \+ -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \+

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# Избегаем установки man-страниц в /usr/share/man/cat*
sed -i -e '/cat./d' documentation/Makefile || exit 1

./configure       \
    --prefix=/usr \
    --enable-shared || exit 1

make || exit 1

# NOTE: Тесты для пакета интерактивны.
# bin/test/unittests
#
# Кроме того, в каталоге ./test есть еще набор исполняемых тестовых программ,
# которые можно запускать индивидуально.

make docdir="/usr/share/doc/${PRGNAME}-${VERSION}" install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

rm -fv /usr/lib/libfltk*.a

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (The Fast Light Tool Kit)
#
# The Fast Light Tool Kit ("FLTK", pronounced "fulltick") is a a cross-
# platform C++ GUI toolkit for UNIX/Linux (X11), Windows, and MacOS X. FLTK
# provides modern GUI functionality without the bloat and supports 3D graphics
# via OpenGL and its built-in GLUT emulation. It was originally developed by
# Mr. Bill Spitzak and is currently maintained by a small group of developers
# across the world with a central repository in the US.
#
# Home page: https://www.${PRGNAME}.org/
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/releases/download/release-${VERSION}/${PRGNAME}-${VERSION}-source.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
