#! /bin/bash

PRGNAME="ibus"

### ibus (Intelligent Input Bus for Linux)
# Интеллектуальная система ввода с клавиатуры, которая предоставляет
# полнофункциональный и удобный пользовательский интерфейс (всплывающие
# подсказки, в которых предлагаются варианты символов, языковые панели и т.д.)

# Required:    dconf
#              iso-codes
#              vala
# Recommended: gobject-introspection
#              gtk+2                  (to build IM module for it)
#              libnotify
# Optional:    gtk+3                  (to build IM module for it)
#              gtk4                   (to build IM module for it)
#              python3-dbus
#              python3-pygobject3
#              gtk-doc
#              libxkbcommon
#              wayland
#              emojione      (https://joypixels.com/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
UNICODE_UCD="/usr/share/unicode/ucd"
mkdir -pv "${TMP_DIR}${UNICODE_UCD}"

GTK2="--disable-gtk2"
GTK3="--disable-gtk3"
GTK4="--disable-gtk4"
WAYLAND="--disable-wayland"
GTK_DOC="--disable-gtk-doc"
PYTHON_LIB="--disable-python-library"
EMOJIONE="--disable-emoji-dict"

command -v gtk-demo        &>/dev/null && GTK2="--enable-gtk2"
command -v gtk3-demo       &>/dev/null && GTK3="--enable-gtk3"
command -v gtk4-demo       &>/dev/null && GTK4="--enable-gtk4"
command -v wayland-scanner &>/dev/null && WAYLAND="--enable-wayland"
# command -v gtkdoc-check    &>/dev/null && GTK_DOC="--enable-gtk-doc"

[ -f /usr/lib/pkgconfig/dbus-python.pc ]                && \
    [ -f /usr/lib/pkgconfig/pygobject-3.0.pc ]          && \
    PYTHON_LIB="--enable-python-library"

[ -d /usr/lib/node_modules/emojione ]  && EMOJIONE="--enable-emoji-dict"

mkdir -pv "${UNICODE_UCD}"
unzip -uo "${SOURCES}/UCD.zip" -d "${UNICODE_UCD}"
unzip -uo "${SOURCES}/UCD.zip" -d "${TMP_DIR}${UNICODE_UCD}"

# исправим проблему с устаревшими записями схем
sed -i 's@/desktop/ibus@/org/freedesktop/ibus@g' \
    data/dconf/org.freedesktop.ibus.gschema.xml

./configure                    \
    --prefix=/usr              \
    --sysconfdir=/etc          \
    --disable-python2          \
    --with-python=python3      \
    --disable-systemd-services \
    "${GTK2}"                  \
    "${GTK3}"                  \
    "${GTK4}"                  \
    "${WAYLAND}"               \
    "${GTK_DOC}"               \
    "${PYTHON_LIB}"            \
    "${EMOJIONE}" || exit 1

# удалим сгенерированный файл, который не был удален при создании архива с
# исходниками
rm -f tools/main.c

make || exit 1
# make -k check
make install DESTDIR="${TMP_DIR}"

[[ "x${GTK_DOC}" == "x--disable-gtk-doc" ]] && \
    rm -rf "${TMP_DIR}/usr/share/gtk-doc"

find "${TMP_DIR}/usr/share/man/" -type f -name "*.gz" -exec gunzip -v {} \;

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# если установлены gtk+2 и/или gtk+3 будет установлен модуль ibus IM для
# gtk+{2,3}. Обновим файл кэша gtk+{2,3}, чтобы приложения на базе GTK могли
# найти недавно установленный модуль IM и использовать ibus в качестве метода
# ввода. GTK4 не требует файла кэша для модулей IM.
command -v gtk-query-immodules-2.0 &>/dev/null && \
    gtk-query-immodules-2.0 --update-cache
command -v gtk-query-immodules-3.0 &>/dev/null && \
    gtk-query-immodules-3.0 --update-cache

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Intelligent Input Bus for Linux)
#
# IBus is an Intelligent Input Bus. It is a new input framework for Linux. It
# provides a full featured and user friendly input method user interface. It
# also may help developers create an input method easily.
#
# Home page: https://github.com/${PRGNAME}/${PRGNAME}/wiki
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
