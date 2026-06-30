#! /bin/bash

PRGNAME="libnftnl"

### libnftnl (user-space interface to the kernel nf_tables subsystem)
# Специализированная C-библиотека, которая предоставляет удобный интерфейс для
# программной настройки встроенного фаервола Linux (nftables). Берет на себя
# всю сложную работу по формированию и разбору низкоуровневых
# Netlink-сообщений, позволяя разработчикам легко создавать, удалять и изменять
# правила фильтрации трафика напрямую в ядре.

# Required:    libmnl
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure \
    --prefix=/usr || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (user-space interface to the kernel nf_tables subsystem)
#
# libnftnl is a userspace library providing a low-level netlink programming
# interface (API) to the in-kernel nf_tables subsystem. This library is
# currently used by nftables.
#
# Home page: https://www.netfilter.org/projects/${PRGNAME}/
# Download:  https://www.netfilter.org/pub/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
