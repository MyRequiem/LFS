#! /bin/bash

PRGNAME="libarchive"

### libarchive (archive reading library)
# Портативная и эффективная библиотека C, которая может читать и писать
# потоковые архивы в различных форматах, а также включает реализацию общих
# инструментов командной строки tar, cpio и zcat

# Required:    no
# Recommended: libxml2
# Optional:    lzo
#              nettle
#              pcre2

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

LZO2="--without-lzo2"
NETTLE="--without-nettle"

[ -x /usr/lib/liblzo2.so ]         && LZO2="--with-lzo2"
command -v nettle-hash &>/dev/null && NETTLE="--with-nettle"

./configure       \
    --prefix=/usr \
    "${LZO2}"     \
    "${NETTLE}"   \
    --disable-static \
    --without-expat || exit 1

make || exit 1
# LC_ALL=C.UTF-8 make check
make install DESTDIR="${TMP_DIR}"

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
# Home page: http://${PRGNAME}.org
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
