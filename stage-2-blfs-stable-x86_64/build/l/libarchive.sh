#! /bin/bash

PRGNAME="libarchive"

### libarchive (archive reading library)
# Универсальная библиотека, позволяющая программам работать с архивами разных
# форматов (tar, zip, iso и др.) как с обычными каталогами, а также включает в
# себя реализацию общих инструментов командной строки bsdcat, bsdcpio, bsdtar,
# bsdunzip

# Required:    no
# Recommended: no
# Optional:    libxml2
#              lzo
#              nettle

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

LZO2="--without-lzo2"
pkg-config lzo2 &>/dev/null && LZO2="--with-lzo2"

./configure          \
    --prefix=/usr    \
    --disable-static \
    "${LZO2}" || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

# создадим ссылку
#    unzip -> bsdunzip
# т.к. пакет unzip больше не поддерживается (unmaintained)
ln -sfv bsdunzip "${TMP_DIR}/usr/bin/unzip"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (archive reading library)
#
# Libarchive is a programming library that can create and read several
# different streaming archive formats, including most popular TAR variants and
# several CPIO formats. It can also write SHAR archives.
#
# Home page: https://${PRGNAME}.org
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
