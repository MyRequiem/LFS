#! /bin/bash

PRGNAME="lsb-tools"
ARCH_NAME="LSB-Tools"

### LSB-Tools (tools for Linux Standards Base conformance)
# Инструменты для соответствия Linux Standards Base (LSB)
#
# утилиты для активации/деактивации скриптов автозапуска в /etc/rc.d/init.d/
#    /usr/lib/lsb/install_initd
#    /usr/lib/lsb/remove_initd
# утилита для определения информации о доступных модулях LSB
#    /usr/bin/lsb_release

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -p "${TMP_DIR}"

make || exit 1
make install
make install DESTDIR="${TMP_DIR}"

rm /usr/sbin/lsbinstall
rm "${TMP_DIR}/usr/sbin/lsbinstall"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (tools for Linux Standards Base conformance)
#
# The LSB-Tools package includes tools for Linux Standards Base (LSB)
# conformance.
#
# Home page: https://github.com/lfs-book/${ARCH_NAME}/
# Download:  https://github.com/lfs-book/${ARCH_NAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
