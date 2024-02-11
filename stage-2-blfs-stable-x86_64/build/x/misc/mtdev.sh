#! /bin/bash

PRGNAME="mtdev"

### mtdev (Multitouch Protocol Translation Library)
# Отдельная библиотека, которая преобразует все варианты события ядра MT.
# Основная часть кода mtdev существует с 2008 года как часть драйвера
# Multitouch X.

# Required:    no
# Recommended: no
# Optional:    no

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

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Multitouch Protocol Translation Library)
#
# mtdev is a stand-alone library which transforms all variants of kernel MT
# events to the slotted type B protocol. The events put into mtdev may be from
# any MT device, specifically type A without contact tracking, type A with
# contact tracking, or type B with contact tracking. The bulk of the mtdev code
# has been out there since 2008 as part of the Multitouch X Driver. With this
# package, finger tracking and seamless MT protocol handling is available under
# a free license.
#
# Home page: http://bitmath.org/code/${PRGNAME}/
# Download:  http://bitmath.org/code/${PRGNAME}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
