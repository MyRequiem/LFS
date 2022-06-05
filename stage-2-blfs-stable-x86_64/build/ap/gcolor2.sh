#! /bin/bash

PRGNAME="gcolor2"

### gcolor2 (GTK+2 color selector)
# Простое приложение для выбора и определения цвета.

# Required:    gtk+2
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
ICONS="/usr/share/icons/hicolor/scalable/apps"
APPLICATIONS="/usr/share/applications"
mkdir -pv "${TMP_DIR}"{"${ICONS}","${APPLICATIONS}"}

# добавляем путь к определениям цветов rgb.txt, предоставленным X11
patch --verbose -p1 \
    -i "${SOURCES}/${PRGNAME}-${VERSION}-color_definition_path.patch" || exit 1
# исправляем segfaults на x86_64 и удалим некоторые предупреждения компиляции
patch --verbose -p1 \
    -i "${SOURCES}/${PRGNAME}-${VERSION}-amd64_segfault.patch"        || exit 1
# исправим ошибку, связанную с обратными вызовами на main.o (спасибо Gentoo)
patch --verbose -p1 \
    -i "${SOURCES}/${PRGNAME}-${VERSION}-fno-common.patch"            || exit 1
# установим корректное определение класса символов в скрипте configure
sed -i '/gentoo_ltmain_version/s/\[:space:\]/[&]/g' configure         || exit 1

CFLAGS="-O2 -fPIC"          \
CXXFLAGS="-O2 -fPIC"        \
./configure                 \
    --prefix=/usr           \
    --sysconfdir=/etc       \
    --localstatedir=/var    \
    --mandir=/usr/share/man \
    --infodir=/usr/share/info || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

cp "${SOURCES}/${PRGNAME}.svg" "${TMP_DIR}${ICONS}"

cat << EOF > "${TMP_DIR}${APPLICATIONS}/${PRGNAME}.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=gcolor2
GenericName=Color Chooser
Comment=Pick colors via numeric input, color wheel, or named colors
Icon=gcolor2
Exec=gcolor2
Terminal=false
Categories=Graphics;GTK;
EOF

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GTK+2 color selector)
#
# gcolor2 is a simple color selector application that is not dependent on any
# specific desktop environment. It provides the color wheel method, input box
# method, color-picker method, and the ability to save user-defined colors.
#
# Home page: http://${PRGNAME}.sourceforge.net/
# Download:  http://downloads.sourceforge.net/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
