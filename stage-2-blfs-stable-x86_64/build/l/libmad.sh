#! /bin/bash

PRGNAME="libmad"

### libmad (MAD - high-quality MPEG Audio Decoder)
# Высококачественный MPEG аудиодекодер, поддерживающий 24-битный вывод

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/usr/lib/pkgconfig"

patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-fixes-1.patch" || exit 1

sed "s@AM_CONFIG_HEADER@AC_CONFIG_HEADERS@g" -i configure.ac &&

# без этих файлов autoreconf может возвращать ошибку
touch NEWS AUTHORS ChangeLog
autoreconf -fi || exit 1

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

# некоторые пакеты проверяют наличие файла pkg-config для libmad
cat << EOF > "${TMP_DIR}/usr/lib/pkgconfig/mad.pc"
prefix=/usr
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: mad
Description: MPEG audio decoder
Requires:
Version: ${VERSION}
Libs: -L\${libdir} -lmad
Cflags: -I\${includedir}
EOF

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (MAD - high-quality MPEG Audio Decoder)
#
# MAD (libmad) is a high-quality MPEG audio decoder. It currently supports
# MPEG-1 and the MPEG-2 extension to Lower Sampling Frequencies, as well as the
# so-called MPEG 2.5 format. All three audio layers (Layer I, Layer II, and
# Layer III a.k.a. MP3) are fully implemented. Because MAD provides full 24-bit
# PCM output, applications using MAD are able to produce high quality audio.
#
# Home page: https://www.underbit.com/products/mad/
# Download:  https://downloads.sourceforge.net/mad/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
