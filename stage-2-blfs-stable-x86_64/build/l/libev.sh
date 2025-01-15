#! /bin/bash

PRGNAME="libev"

### libev (a high-performance event loop/model)
# Полнофункциональный и высокопроизводительный пакет обработки событий,
# созданный по образцу libevent, но без его ограничений и ошибок. Используется
# в GNU Virtual Private Ethernet, rxvt-unicode, auditd и многих других
# программах.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
HEADER_SUBFOLDER="/usr/include/${PRGNAME}"
mkdir -pv "${TMP_DIR}${HEADER_SUBFOLDER}"

./configure       \
    --prefix=/usr \
    --enable-static=no || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

# чтобы не конфликтовать с пакетом libevent, мы перемещаем заголовок event.h во
# вложенную директорию /usr/include/libev/ Затем, если для сборки какого-либо
# софта требуется этот заголовок, нужно явно указать его местоположение
#    CPPFLAGS="-I/usr/include/libev"
# Например для сборки пакетов 'nghttp2' и 'i3' этот заголовок не нужен
mv "${TMP_DIR}/usr/include/event.h" "${TMP_DIR}${HEADER_SUBFOLDER}/"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a high-performance event loop/model)
#
# Libev is modelled (very loosely) after libevent and the Event perl module,
# but is faster, scales better and is more correct, and also more featureful.
#
# Home page: https://software.schmorp.de/pkg/${PRGNAME}.html
# Download:  https://dist.schmorp.de/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
