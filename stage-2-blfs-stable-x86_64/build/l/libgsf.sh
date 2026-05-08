#! /bin/bash

PRGNAME="libgsf"

### libgsf (structured file I/O library)
# Библиотека для чтения и записи файлов со сложной внутренней структурой
# (например, старых документов Microsoft Office). Она позволяет программам
# корректно извлекать данные из таких «архивов».

# Required:    glib
#              libxml2
# Recommended: gdk-pixbuf    (для сборки gsf-office-thumbnailer)
# Optional:    gtk-doc

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
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
