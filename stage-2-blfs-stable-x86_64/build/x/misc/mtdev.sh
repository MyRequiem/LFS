#! /bin/bash

PRGNAME="mtdev"

### mtdev (Multitouch Protocol Translation Library)
# Библиотека-посредник, которая собирает данные от различных сенсорных панелей
# и экранов мультитач. Она преобразует «сырые» сигналы от железа в единый
# формат, понятный для драйверов и приложений.

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

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
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
# Home page: https://bitmath.org/code/${PRGNAME}/
# Download:  https://bitmath.org/code/${PRGNAME}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
