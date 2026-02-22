#! /bin/bash

PRGNAME="gnome-backgrounds"

### GNOME Backgrounds (GNOME Backgrounds)
# Коллекция графических файлов, которые можно использовать в качестве обоев в
# среде рабочего стола GNOME. Кроме того, пакет создает правильную структуру
# каталогов, чтобы пользователь мог добавлять в коллекцию свои собственные
# файлы.

# Required:    libjxl    (runtime)
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup       \
    --prefix=/usr \
    .. || exit 1

# пакет не имеет набора тестов
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GNOME Backgrounds)
#
# The GNOME Backgrounds package contains a collection of graphics files which
# can be used as backgrounds in the GNOME Desktop environment. Additionally,
# the package creates the proper framework and directory structure so that you
# can add your own files to the collection.
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
