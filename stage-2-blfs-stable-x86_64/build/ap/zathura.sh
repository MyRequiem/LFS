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

# Required:    glib
#              girara
#              poppler
#              djvulibre   (для сборки плагина zathura-djvu) https://djvu.sourceforge.net/
#              libspectre  (для сборки плагина zathura-ps)
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
PIXMAPS="/usr/share/pixmaps"
MAN_DIR="/usr/share/man"
mkdir -pv "${TMP_DIR}"{${PIXMAPS},"${MAN_DIR}"/{man1,man5}}

mkdir build
cd build || exit 1

meson                    \
    --prefix=/usr        \
    --buildtype=release  \
    --sysconfdir=/etc    \
    --localstatedir=/var \
    -Dtests="disabled"   \
    .. || exit 1

ninja || exit 1
DESTDIR="${TMP_DIR}" ninja install

cp "${SOURCES}/${PRGNAME}.1"   "${TMP_DIR}${MAN_DIR}/man1/"
cp "${SOURCES}/${PRGNAME}rc.5" "${TMP_DIR}${MAN_DIR}/man5/"
cp "${SOURCES}/${PRGNAME}.png" "${TMP_DIR}${PIXMAPS}/"

###
# ============================= сборка плагинов ================================
###
# для сборки плагинов требуется пакет zathura, который может быть еще не
# установлен в системе, поэтому добавим в PKG_CONFIG_PATH путь к временной
# директории, где пакет zathura уже собран
export PKG_CONFIG_PATH="${TMP_DIR}/usr/lib/pkgconfig:${PKG_CONFIG_PATH}"

########################################
# zathura-pdf-poppler
PLUG_NAME="${PRGNAME}-pdf-poppler"
########################################
PLUG_NAME_VERSION="$(find "${SOURCES}" -type f \
    -name "${PLUG_NAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

tar xvf "${SOURCES}/${PLUG_NAME}-${PLUG_NAME_VERSION}"*.tar.?z* || exit 1
cd "${PLUG_NAME}-${PLUG_NAME_VERSION}" || exit 1

mkdir build
cd build || exit 1

# для сборки плагина zathura-pdf-poppler нужны заголовки
# /usr/include/zathura/*. Если пакет zathura устанавливается в первый раз,
# заголовки еще не были установлены в систему, поэтому явно укажем их
# местоположение во временной директории сборки
CPPFLAGS="-I${TMP_DIR}/usr/include/"              \
meson                                             \
    --prefix=/usr                                 \
    --buildtype=release                           \
    --sysconfdir=/etc                             \
    --localstatedir=/var                          \
    -Dplugindir="/usr/lib/${PRGNAME}/pdf-poppler" \
    .. || exit 1

ninja || exit 1
DESTDIR="${TMP_DIR}" ninja install

# ссылки в /usr/lib/zathura
#    libpdf-poppler.so -> pdf-poppler/libpdf-poppler.so
#    pdf.so            -> pdf-poppler/libpdf-poppler.so
ln -s pdf-poppler/libpdf-poppler.so \
    "${TMP_DIR}/usr/lib/${PRGNAME}/libpdf-poppler.so"
ln -s pdf-poppler/libpdf-poppler.so "${TMP_DIR}/usr/lib/${PRGNAME}/pdf.so"

cd .. || exit 1

########################################
# zathura-djvu
PLUG_NAME="${PRGNAME}-djvu"
########################################
PLUG_NAME_VERSION="$(find "${SOURCES}" -type f \
    -name "${PLUG_NAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

tar xvf "${SOURCES}/${PLUG_NAME}-${PLUG_NAME_VERSION}"*.tar.?z* || exit 1
cd "${PLUG_NAME}-${PLUG_NAME_VERSION}" || exit 1

mkdir build
cd build || exit 1

# для сборки плагина zathura-djvu нужны заголовки /usr/include/zathura/*. Если
# пакет zathura устанавливается в первый раз, заголовки еще не были установлены
# в систему, поэтому явно укажем их местоположение во временной директории
# сборки
CPPFLAGS="-I${TMP_DIR}/usr/include/"       \
meson                                      \
    --prefix=/usr                          \
    --buildtype=release                    \
    --sysconfdir=/etc                      \
    --localstatedir=/var                   \
    -Dplugindir="/usr/lib/${PRGNAME}/djvu" \
    .. || exit 1

ninja || exit 1
DESTDIR="${TMP_DIR}" ninja install

# ссылки в /usr/lib/zathura
#    libdjvu.so -> djvu/libdjvu.so
#    djvu.so    -> djvu/libdjvu.so
ln -s djvu/libdjvu.so "${TMP_DIR}/usr/lib/${PRGNAME}/libdjvu.so"
ln -s djvu/libdjvu.so "${TMP_DIR}/usr/lib/${PRGNAME}/djvu.so"

########################################
# zathura-ps
PLUG_NAME="${PRGNAME}-ps"
########################################
PLUG_NAME_VERSION="$(find "${SOURCES}" -type f \
    -name "${PLUG_NAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

tar xvf "${SOURCES}/${PLUG_NAME}-${PLUG_NAME_VERSION}"*.tar.?z* || exit 1
cd "${PLUG_NAME}-${PLUG_NAME_VERSION}" || exit 1

mkdir build
cd build || exit 1

# для сборки плагина zathura-ps нужны заголовки /usr/include/zathura/*. Если
# пакет zathura устанавливается в первый раз, заголовки еще не были установлены
# в систему, поэтому явно укажем их местоположение во временной директории
# сборки
CPPFLAGS="-I${TMP_DIR}/usr/include/"     \
meson                                    \
    --prefix=/usr                        \
    --buildtype=release                  \
    --sysconfdir=/etc                    \
    --localstatedir=/var                 \
    -Dplugindir="/usr/lib/${PRGNAME}/ps" \
    .. || exit 1

ninja || exit 1
DESTDIR="${TMP_DIR}" ninja install

# ссылки в /usr/lib/zathura
#    libps.so -> ps/libps.so
#    ps.so    -> ps/libps.so
ln -s ps/libps.so "${TMP_DIR}/usr/lib/${PRGNAME}/libps.so"
ln -s ps/libps.so "${TMP_DIR}/usr/lib/${PRGNAME}/ps.so"

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
#    - zathura-pdf-poppler  (PDF support for zathura)
#    - zathura-djvu         (DjVU support for zathura)
#    - zathura-ps           (PostScript support for zathura)
#
# Home page: https://github.com/pwmt/${PRGNAME}
# Download:  https://github.com/pwmt/${PRGNAME}/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
