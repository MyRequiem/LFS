#! /bin/bash

PRGNAME="zathura"

### zathura (a PDF viewer focusing on keyboard interaction)
# Программа для просмотра PDF-файлов, основанная на библиотеке рендеринга
# poppler и наборе инструментов GTK+

# Required:    girara
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
    -Dtests="disabled"   \
    --localstatedir=/var \
    .. || exit 1

ninja || exit 1
DESTDIR="${TMP_DIR}" ninja install

DESKTOP="$(find "${TMP_DIR}/usr/share/applications" -type f -name "*.desktop")"
mv "${DESKTOP}" "$(dirname "${DESKTOP}")/${PRGNAME}.desktop"

ICONS="$(find "${TMP_DIR}/usr/share/icons" -type f -name "*.png")"
for ICON in ${ICONS}; do
    mv "${ICON}" "$(dirname "${ICON}")/${PRGNAME}.png"
done

ICONS="$(find "${TMP_DIR}/usr/share/icons" -type f -name "*.svg")"
for ICON in ${ICONS}; do
    mv "${ICON}" "$(dirname "${ICON}")/${PRGNAME}.svg"
done

cp "${SOURCES}/${PRGNAME}.1"   "${TMP_DIR}${MAN_DIR}/man1/"
cp "${SOURCES}/${PRGNAME}rc.5" "${TMP_DIR}${MAN_DIR}/man5/"
cp "${SOURCES}/${PRGNAME}.png" "${TMP_DIR}${PIXMAPS}"

# собираем zathura-pdf-poppler плагин
PDF_POPPLER="${PRGNAME}-pdf-poppler"
PDF_POPPLER_VERSION="$(find "${SOURCES}" -type f \
    -name "${PDF_POPPLER}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

tar xvf "${SOURCES}/${PDF_POPPLER}-${PDF_POPPLER_VERSION}"*.tar.?z* || exit 1
cd "${PDF_POPPLER}-${PDF_POPPLER_VERSION}" || exit 1

mkdir build
cd build || exit 1

# нужно будет найти пакет zathura, который еще не установлен, поэтому изменим
# PKG_CONFIG_PATH
export PKG_CONFIG_PATH="${TMP_DIR}/usr/lib/pkgconfig:${PKG_CONFIG_PATH}"

# для сборки нужны заголовки /usr/include/zathura/*, которые еще не установлены
# в системе, поэтому явно укажем их местоположение
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

DESKTOP="$(find "${TMP_DIR}/usr/share/applications" -type f \
    -name "*${PDF_POPPLER}.desktop")"
mv "${DESKTOP}" "$(dirname "${DESKTOP}")/${PDF_POPPLER}.desktop"

# ссылка в /usr/lib/zathura
#    pdf.so -> pdf-poppler/libpdf-poppler.so
ln -s pdf-poppler/libpdf-poppler.so "${TMP_DIR}/usr/lib/${PRGNAME}/pdf.so"

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
# Home page: https://github.com/pwmt/${PRGNAME}
# Download:  https://github.com/pwmt/${PRGNAME}/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
