#! /bin/bash

PRGNAME="w3m"

### w3m (text based web browser and pager)
# Консольный клиент World Wide Web (браузер) с возможностью отображения
# HTML-таблиц, фреймов и изображений, а так же поддерживает просмотр с
# вкладками.

# Required:    gc
# Recommended: no
# Optional:    glib
#              imlib2
#              gdk-pixbuf

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
ARCH_VERSION="$(find "${SOURCES}" -type f \
    -name "${PRGNAME}*.tar.?z*" 2>/dev/null | sort | head -n 1 | rev | \
    cut -d . -f 4- | cut -d _ -f 1 | rev)"
VERSION="${ARCH_VERSION//+/_}"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}_${ARCH_VERSION}"*.tar.?z* || exit 1
cd "${PRGNAME}-${ARCH_VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# для gcc>11
SLKCFLAGS="-std=gnu17"
CFLAGS="${SLKCFLAGS}"                    \
CXXFLAGS="${SLKCFLAGS}"                  \
./configure                              \
    --prefix=/usr                        \
    --sysconfdir=/etc                    \
    --localstatedir=/var                 \
    --with-gc                            \
    --with-ssl                           \
    --enable-nls                         \
    --enable-m17n                        \
    --enable-gopher                      \
    --enable-unicode                     \
    --enable-image="x11,fb"              \
    --enable-keymap="w3m"                \
    --disable-mouse                      \
    --disable-w3mmailer                  \
    --with-editor=/usr/bin/vim           \
    --with-browser=google-chrome         \
    --with-termlib="terminfo ncurses"    \
    --with-imagelib="gdk-pixbuf2 imlib2" \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# пакет не имеет наборат тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (text based web browser and pager)
#
# w3m is a World Wide Web (WWW) text based client. It has English, German and
# Japanese help files and an option menu that can be configured to use the
# preferred language. It will display hypertext markup language (HTML)
# documents containing links to files residing on the local system, as well as
# files residing on remote systems. It can display HTML tables, frames, and
# images, and supports tabbed browsing.
#
# Hom page: https://${PRGNAME}.sourceforge.net/
# Download: https://deb.debian.org/debian/pool/main/w/${PRGNAME}/${PRGNAME}_${ARCH_VERSION}.orig.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
