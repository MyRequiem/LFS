#! /bin/bash

PRGNAME="libgsf"

### libgsf (structured file I/O library)
# Библиотека предоставляющая эффективную расширяемую абстракцию ввода-вывода
# для работы с различными форматами структурированных файлов. Например,
# различные текстовые редакторы используют ее для импорта файлов в формате .doc

# Required:    glib
#              libxml2
# Recommended: gdk-pixbuf (для сборки gsf-office-thumbnailer)
# Optional:    7zip
#              gtk-doc
#              --- для тестов ---
#              valgrind
#              unzip      (https://sourceforge.net/projects/infozip/files/UnZip%206.x%20%28latest%29/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (structured file I/O library)
#
# libgsf aims to provide an efficient extensible I/O abstraction for dealing
# with different structured file formats. libgsf is used by libwv2, which is
# used by various word processors to import .doc format files.
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
