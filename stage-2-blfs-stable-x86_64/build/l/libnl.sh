#! /bin/bash

PRGNAME="libnl"

### libnl (Netlink Protocol Library Suite)
# Набор библиотек, предоставляющих API для протокола netlink интерфейса ядра
# Linux

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure           \
    --prefix=/usr     \
    --sysconfdir=/etc \
    --disable-static  || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Netlink Protocol Library Suite)
#
# The libnl suite is a collection of libraries providing APIs to netlink
# protocol based Linux kernel interfaces. Netlink is a IPC mechanism primarily
# between the kernel and user space processes. It was designed to be a more
# flexible successor to ioctl to provide mainly networking related kernel
# configuration and monitoring interfaces.
#
# Home page: https://github.com/thom311/${PRGNAME}
# Download:  https://github.com/thom311/${PRGNAME}/releases/download/${PRGNAME}${VERSION//\./_}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
