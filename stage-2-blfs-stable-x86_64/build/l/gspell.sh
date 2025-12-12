#! /bin/bash

PRGNAME="gspell"

### gspell (spell checking library for GTK+ applications)
# Библиотека для проверки орфографии в среде рабочего стола GNOME, использующая
# движок Hunspell (или Aspell) для поиска ошибок и предложения исправлений в
# текстах приложений, работающих с GNOME, типа Gedit, Evolution и т.д.

# Required:    enchant
#              icu
#              gtk+3
# Recommended: no
# Optional:    glib
#              gtk-doc
#              vala
#              valgrind
#              hunspell    (для тестов) https://hunspell.github.io/

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir gspell-build
cd gspell-build || exit 1

meson setup             \
    --prefix=/usr       \
    --buildtype=release \
    -D gtk_doc=false    \
    .. || exit 1

ninja || exit 1
# тесты проводятся в графической среде
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (spell checking library for GTK+ applications)
#
# The gspell package provides a flexible API to add spell checking to a GTK+
# application
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
