#! /bin/bash

PRGNAME="zathura"

### zathura (a PDF viewer focusing on keyboard interaction)
# Программа для просмотра PDF-файлов, основанная на библиотеке рендеринга
# poppler и наборе инструментов GTK+
#
# Также в состав пакета входят следующие плагины:
#    - zathura-pdf-poppler (поддержка PDF)
#    - zathura-djvu        (поддержка DjVU)
#    - zathura-ps          (поддержка PostScript)

# Required:    gtk+3
#              glib
#              cairo
#              girara
#              json-glib
#              sqlite
#              poppler          (для сборки плагина zathura-pdf-poppler)
#              djvulibre        (для сборки плагина zathura-djvu) https://djvu.sourceforge.net/
#              libspectre       (для сборки плагина zathura-ps)   https://www.freedesktop.org/wiki/Software/libspectre/
# Recommended: no
# Optional:    python3-sphinx   (для сборки man-страниц)
#              texlive
#              libseccomp
#              doxygen

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
PIXMAPS="/usr/share/pixmaps"
MAN_DIR="/usr/share/man"
mkdir -pv "${TMP_DIR}"{${PIXMAPS},"${MAN_DIR}"/{man1,man5}}

mkdir build
cd build || exit 1

# для генерации man-страниц нужен sphinx
#    -D manpages=disabled
# конвертировать изображения в PNG
#    -D convert-icon=enabled
meson setup ..              \
    --prefix=/usr           \
    --buildtype=release     \
    --sysconfdir=/etc       \
    --localstatedir=/var    \
    -D manpages=disabled    \
    -D convert-icon=enabled \
    -D tests=disabled || exit 1

ninja || exit 1
DESTDIR="${TMP_DIR}" ninja install

cp "${SOURCES}/${PRGNAME}.1"   "${TMP_DIR}${MAN_DIR}/man1/"
cp "${SOURCES}/${PRGNAME}rc.5" "${TMP_DIR}${MAN_DIR}/man5/"

cd .. || exit 1

###
# ============================= сборка плагинов ================================
###
# для сборки плагинов требуется пакет zathura, который еще не установлен в
# системе, поэтому добавим в PKG_CONFIG_PATH путь к временной директории, где
# пакет zathura уже собран
export PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:${TMP_DIR}/usr/lib/pkgconfig"

# для сборки плагинов нужны заголовки /usr/include/zathura/* Заголовки еще не
# были установлены в систему, поэтому при конфигурации каждого плагина явно
# указываем местоположение заголовков во временной директории, где zathura уже
# собрана
#    CPPFLAGS="-I${TMP_DIR}/usr/include/"

########################################
### zathura-pdf-poppler
########################################
PLUG_NAME="${PRGNAME}-pdf-poppler"
PDF_POPPLER_VERSION="$(find "${SOURCES}" -type f \
    -name "${PLUG_NAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

tar xvf "${SOURCES}/${PLUG_NAME}-${PDF_POPPLER_VERSION}"*.tar.?z* || exit 1
cd "${PLUG_NAME}-${PDF_POPPLER_VERSION}" || exit 1

mkdir build
cd build || exit 1

CPPFLAGS="-I${TMP_DIR}/usr/include/" \
meson setup ..           \
    --prefix=/usr        \
    --buildtype=release  \
    --sysconfdir=/etc    \
    --localstatedir=/var \
    -D tests=disabled || exit 1

ninja || exit 1
DESTDIR="${TMP_DIR}" ninja install

ln -s libpdf-poppler.so "${TMP_DIR}/usr/lib/${PRGNAME}/pdf.so"

cd .. || exit 1

########################################
### zathura-djvu
########################################
PLUG_NAME="${PRGNAME}-djvu"
DJVU_VERSION="$(find "${SOURCES}" -type f \
    -name "${PLUG_NAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

tar xvf "${SOURCES}/${PLUG_NAME}-${DJVU_VERSION}"*.tar.?z* || exit 1
cd "${PLUG_NAME}-${DJVU_VERSION}" || exit 1

mkdir build
cd build || exit 1

CPPFLAGS="-I${TMP_DIR}/usr/include/" \
meson setup ..           \
    --prefix=/usr        \
    --buildtype=release  \
    --sysconfdir=/etc    \
    --localstatedir=/var \
    -D tests=disabled || exit 1

ninja || exit 1
DESTDIR="${TMP_DIR}" ninja install

ln -s libdjvu.so "${TMP_DIR}/usr/lib/${PRGNAME}/djvu.so"

cd .. || exit 1

########################################
### zathura-ps
########################################
PLUG_NAME="${PRGNAME}-ps"
PS_VERSION="$(find "${SOURCES}" -type f \
    -name "${PLUG_NAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

tar xvf "${SOURCES}/${PLUG_NAME}-${PS_VERSION}"*.tar.?z* || exit 1
cd "${PLUG_NAME}-${PS_VERSION}" || exit 1

mkdir build
cd build || exit 1

CPPFLAGS="-I${TMP_DIR}/usr/include/" \
meson setup ..           \
    --prefix=/usr        \
    --buildtype=release  \
    --sysconfdir=/etc    \
    --localstatedir=/var \
    -D tests=disabled || exit 1

ninja || exit 1
DESTDIR="${TMP_DIR}" ninja install

ln -s libps.so "${TMP_DIR}/usr/lib/${PRGNAME}/ps.so"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a PDF viewer focusing on keyboard interaction)
#
# zathura is a highly customizable and functional PDF viewer based on the
# poppler rendering library and the gtk+ toolkit. The idea behind zathura is an
# application that provides a minimalistic and space saving interface as well
# as an easy usage that mainly focuses on keyboard interaction.
#
# The package also includes the following plugins:
#    - zathura-pdf-poppler  (PDF support)
#    - zathura-djvu         (DjVU support)
#    - zathura-ps           (PostScript support)
#
# Home page: https://pwmt.org/projects/${PRGNAME}/
# Download:  https://pwmt.org/projects/${PRGNAME}/download/${PRGNAME}-${VERSION}.tar.xz
#            https://pwmt.org/projects/${PRGNAME}-pdf-poppler/download/${PRGNAME}-pdf-poppler-${PDF_POPPLER_VERSION}.tar.xz
#            https://pwmt.org/projects/${PRGNAME}-djvu/download/${PRGNAME}-djvu-${DJVU_VERSION}.tar.xz
#            https://pwmt.org/projects/${PRGNAME}-ps/download/${PRGNAME}-ps-${PS_VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
