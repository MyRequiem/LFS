#! /bin/bash

PRGNAME="libdvdread"

### Libdvdread (library for reading DVDs)
# Библиотека предоставляющая функциональные возможности, необходимые для
# доступа ко многим DVD. Она анализирует IFO файлы, читает NAV-блоки и
# выполняет аутентификацию CSS и дешифрование.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

API_DOCS="--disable-apidoc"
# command -v doxygen &>/dev/null && API_DOCS="--enable-apidoc"

./configure          \
    --prefix=/usr    \
    --disable-static \
    "${API_DOCS}"    \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (library for reading DVDs)
#
# libdvdread provides a simple foundation for reading DVD video disks. It
# provides the functionality that is required to access many DVDs. It parses
# IFO files, reads NAV-blocks, and performs CSS authentication and
# descrambling.
#
# Home page: https://www.videolan.org/
# Download:  https://get.videolan.org/${PRGNAME}/${VERSION}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
