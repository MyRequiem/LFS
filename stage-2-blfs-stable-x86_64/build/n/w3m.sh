#! /bin/bash

PRGNAME="w3m"

### w3m (text based web browser and pager)
# Консольный клиент World Wide Web (браузер) с возможностью отображения
# HTML-таблиц, фреймов и изображений, а так же поддерживает просмотр с
# вкладками.

# Required:    glib
#              gtk+2
#              imlib2
#              gc
#              gdk-pixbuf
#              gdk-pixbuf-xlib
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

# архив с патчами от Debian
DEBIAN_PATCHES_ARCH=$(find "${SOURCES}" -type f -name "${PRGNAME}_${VERSION}-*")
tar xvf "${DEBIAN_PATCHES_ARCH}" || exit 1

PATCH_VERSION="$(echo "${DEBIAN_PATCHES_ARCH}" | cut -d - -f 2 | cut -d . -f 1)"
MAIN_VERSION="${VERSION}"
VERSION="${VERSION}_${PATCH_VERSION}"

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
DOC_PATH="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"{"/etc/${PRGNAME}","${DOC_PATH}"}

# patches from Debian
while read -r PATCH; do
    patch -p1 --verbose < "debian/patches/${PATCH}" || exit 1
done < debian/patches/series

MOUSE="--disable-mouse"
MAILER="--disable-w3mmailer"
EDITOR="/usr/bin/vim"
BROWSER="/usr/bin/firefox"

./configure                           \
    --prefix=/usr                     \
    --sysconfdir=/etc                 \
    --localstatedir=/var              \
    --with-gc                         \
    --with-ssl                        \
    --enable-nls                      \
    --enable-m17n                     \
    --enable-gopher                   \
    --enable-unicode                  \
    --enable-image="x11,fb"           \
    --enable-keymap="w3m"             \
    "${MOUSE}"                        \
    "${MAILER}"                       \
    --with-editor="${EDITOR}"         \
    --with-browser="${BROWSER}"       \
    --docdir="${DOC_PATH}"            \
    --with-termlib="terminfo ncurses" \
    --with-imagelib="gtk2 gdk-pixbuf2 imlib2" || exit 1

make || exit 1
# пакет не имеет наборат тестов
make install DESTDIR="${TMP_DIR}"

# документация
for DOC in ChangeLog NEWS doc; do
    cp -a "${DOC}" "${TMP_DIR}${DOC_PATH}"
done
mv "${TMP_DIR}${DOC_PATH}/doc" "${TMP_DIR}${DOC_PATH}/tutorial"
rm -rf "${TMP_DIR}${DOC_PATH}/tutorial/CVS"

# конфиги
install -m 644 debian/w3mconfig "${TMP_DIR}/etc/${PRGNAME}/config"
install -m 644 debian/mailcap   "${TMP_DIR}/etc/${PRGNAME}/mailcap"

W3M_CONFIG="/etc/${PRGNAME}/config"
if [ -f "${W3M_CONFIG}" ]; then
    mv "${W3M_CONFIG}" "${W3M_CONFIG}.old"
fi

MAILCAP="/etc/${PRGNAME}/mailcap"
if [ -f "${MAILCAP}" ]; then
    mv "${MAILCAP}" "${MAILCAP}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${W3M_CONFIG}"
config_file_processing "${MAILCAP}"

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
# Hom page: http://${PRGNAME}.sourceforge.net/
# Download: https://jztkft.dl.sourceforge.net/project/${PRGNAME}/${PRGNAME}/${PRGNAME}-${MAIN_VERSION}/${PRGNAME}-${MAIN_VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
