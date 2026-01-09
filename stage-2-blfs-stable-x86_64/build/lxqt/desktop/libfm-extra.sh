#! /bin/bash

PRGNAME="libfm-extra"
ARCH_NAME="libfm"

### libfm-extra (library required by the menu-cache-gen program)
# Библиотека, необходимая для программы menu-cache-gen, установливаемая с
# пакетом 'menu-cache'

# Required:    glib
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# отключает все компоненты, кроме библиотеки libfm-extra
#    --with-extra-only
# отключает поддержку GTK+, поскольку для этого пакета в этом нет необходимости
#    --with-gtk=no
./configure           \
    --prefix=/usr     \
    --sysconfdir=/etc \
    --with-extra-only \
    --with-gtk=no     \
    --disable-static || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (library required by the menu-cache-gen program)
#
# The libfm-extra package contains a library and other files required by the
# menu-cache-gen program in /usr/bin/libexec installed by menu-cache package
#
# Home page: https://downloads.sourceforge.net/pcmanfm/
# Download:  https://downloads.sourceforge.net/pcmanfm/${ARCH_NAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
