#! /bin/bash

PRGNAME="menu-cache"

### menu-cache (creating and utilizing caches application menus)
# Библиотека для создания и использования кеша для ускорения манипуляций с меню
# приложений, определенных freedesktop.org

# Required:    gtk-doc
#              libfm-extra
# Recommended: no
# Optional:    xdg-utils

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

sh autogen.sh     &&
./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (creating and utilizing caches application menus)
#
# The Menu Cache package contains a library for creating and utilizing caches
# to speed up the manipulation for freedesktop.org defined application menus
#
# Home page: https://github.com/lxde/${PRGNAME}/
# Download:  https://github.com/lxde/${PRGNAME}/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
