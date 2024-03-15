#! /bin/bash

PRGNAME="liba52"
ARCH_NAME="a52dec"

### Liba52 (library for decoding ATSC A/52 streams)
# Библиотека для декодирования потоков ATSC A/52 (также известных как AC-3).
# Стандарт A/52 используется во множестве приложений для работы с цифровыми
# телевизорами и DVD

# Required:    no
# Recommended: no
# Optional:    djbfft (https://cr.yp.to/djbfft.html)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure                 \
    --prefix=/usr           \
    --mandir=/usr/share/man \
    --enable-shared         \
    --disable-static        \
    CFLAGS="-g -O2 -fPIC" || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

# копируем заголовок a52_internal.h в /usr/include/a52dec для того, чтобы такие
# пакеты как 'xine-lib' могли компилироваться и компоноваться с уже
# установленным в системе liba52
cp "${PRGNAME}/a52_internal.h" "${TMP_DIR}/usr/include/${ARCH_NAME}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (library for decoding ATSC A/52 streams)
#
# liba52 is a free library for decoding ATSC A/52 (also known as AC-3) streams.
# The A/52 standard is used in a variety of applications, including digital
# television and DVD.
#
# Home page: https://${PRGNAME}.sourceforge.net/
# Download:  http://ftp.osuosl.org/pub/blfs/conglomeration/${ARCH_NAME}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
