#! /bin/bash

PRGNAME="lsb-tools"
ARCH_NAME="LSB-Tools"

### LSB-Tools (tools for Linux Standards Base conformance)
# Инструменты для соответствия Linux Standards Base (LSB)
#
# утилиты для активации/деактивации скриптов в /etc/rc.d/init.d
#    /usr/lib/lsb/install_initd
#    /usr/lib/lsb/remove_initd
# утилита для определения информации о доступных модулях LSB
#    /usr/bin/lsb_release

# http://www.linuxfromscratch.org/blfs/view/stable/general/lsb-tools.html

# Home page: https://github.com/djlucas/LSB-Tools/
# Download:  https://github.com/djlucas/LSB-Tools/releases/download/v0.6/LSB-Tools-0.6.tar.gz

# Required: no
# Optional: no

ROOT="/root"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

python3 setup.py build || exit 1
python3 setup.py install --optimize=1  --root="${TMP_DIR}"

# исправим ошибку в названии скрипта
mv "${TMP_DIR}/usr/sbin"/{remove_intid,remove_initd}

cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (tools for Linux Standards Base conformance)
#
# The LSB-Tools package includes tools for Linux Standards Base (LSB)
# conformance.
#
# Home page: https://github.com/djlucas/${ARCH_NAME}/
# Download:  https://github.com/djlucas/${ARCH_NAME}/releases/download/v${VERSION}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
