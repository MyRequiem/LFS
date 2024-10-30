#! /bin/bash

PRGNAME="feh"

### feh (image viewer)
# Быстрый и легкий просмотрщик изображений, использующий Imlib2

# Required:    libpng
#              imlib2 (собранный с giflib для тестов)
# Recommended: curl
# Optional:    libexif
#              libjpeg-turbo
#              imagemagick
#              perl-test-command (для тестов)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

HELP=1
EXIF=0
CURL=0

[ -x /usr/lib/libexif.so ]  && EXIF=1
command -v curl &>/dev/null && CURL=1

# добавим версию к названию каталога с документацией
sed -i "s:doc/feh:&-${VERSION}:" config.mk || exit 1

make               \
    PREFIX=/usr    \
    help=${HELP}   \
    exif="${EXIF}" \
    curl="${CURL}"

# make test
make PREFIX=/usr install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (image viewer)
#
# feh is a fast, lightweight image viewer which uses Imlib2. It is
# commandline-driven and supports multiple images through slideshows, thumbnail
# browsing or multiple windows, and montages or index prints (using TrueType
# fonts to display file info). Advanced features include fast dynamic zooming,
# progressive loading, loading via HTTP (with reload support for watching
# webcams), recursive file opening (slideshow of a directory hierarchy), and
# mouse wheel/keyboard control.
#
# Home page: https://${PRGNAME}.finalrewind.org
# Download:  https://${PRGNAME}.finalrewind.org/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
