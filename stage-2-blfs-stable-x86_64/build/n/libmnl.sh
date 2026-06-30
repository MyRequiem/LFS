#! /bin/bash

PRGNAME="libmnl"

### libmnl (user-space library oriented to Netlink developers)
# Минималистичная C-библиотека, которая упрощает обмен данными между
# программами и ядром Linux через сетевые сокеты Netlink. Избавляет
# разработчиков от рутины и частых ошибок, предоставляя простые инструменты для
# сборки, валидации и разбора низкоуровневых сетевых сообщений ядра.

# Required:    no
# Recommended: no
# Optional:    doxygen

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure \
    --prefix=/usr || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (user-space library oriented to Netlink developers)
#
# libmnl is a minimalistic user-space library oriented to Netlink developers.
# There are a lot of common tasks in parsing, validating, constructing of both
# the Netlink header and TLVs that are repetitive and easy to get wrong. This
# library aims to provide simple helpers that allows you to re-use code and to
# avoid re-inventing the wheel.
#
# Home page: https://www.netfilter.org/projects/${PRGNAME}/
# Download:  https://netfilter.org/projects/${PRGNAME}/files/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
