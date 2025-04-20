#! /bin/bash

PRGNAME="ibus"

### ibus (Intelligent Input Bus for Linux)
# Интеллектуальная система ввода с клавиатуры, которая предоставляет
# полнофункциональный и удобный пользовательский интерфейс (всплывающие
# подсказки, в которых предлагаются варианты символов, языковые панели и т.д.)

# Required:    dconf
#              iso-codes
#              vala
# Recommended: glib
#              gtk+3                  (для сборки IM модуля)
#              libnotify
# Optional:    gtk4                   (для сборки IM модуля)
#              gtk-doc
#              python3-dbus
#              python3-pygobject3
#              libxkbcommon
#              wayland
#              emojione               (https://joypixels.com/)
#              libdbusmenu            (https://launchpad.net/libdbusmenu)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
UNICODE_UCD="/usr/share/unicode/ucd"
mkdir -pv "${TMP_DIR}${UNICODE_UCD}"

mkdir -pv "${UNICODE_UCD}"
unzip -uo "${SOURCES}/UCD.zip" -d "${UNICODE_UCD}"
unzip -uo "${SOURCES}/UCD.zip" -d "${TMP_DIR}${UNICODE_UCD}"

# исправим проблему с устаревшими записями схем
sed -e 's@/desktop/ibus@/org/freedesktop/ibus@g' \
    -i data/dconf/org.freedesktop.ibus.gschema.xml

# удалим ссылки на gtk-doc в конфигурации
sed '/docs/d;/GTK_DOC/d' -i Makefile.am configure.ac

SAVE_DIST_FILES=1 NOCONFIGURE=1 ./autogen.sh || exit 1
PYTHON=python3                 \
./configure                    \
    --prefix=/usr              \
    --sysconfdir=/etc          \
    --disable-python2          \
    --disable-appindicator     \
    --disable-emoji-dict       \
    --disable-gtk2             \
    --disable-systemd-services || exit 1

make || exit 1
# make -k check
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# обновим файл кэша gtk+3, чтобы приложения на базе GTK могли найти недавно
# установленный модуль IM и использовать ibus в качестве метода ввода. GTK4 не
# требует файла кэша для модулей IM.
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
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
