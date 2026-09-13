#! /bin/bash

PRGNAME="pciutils"

### pciutils (PCI utilities)
# Набор утилит для просмотра информации об устройствах, подключенных к шине
# PCI, например, видеокарт или сетевых адаптеров (lspci), проверки их состояния
# и настройки их регистров конфигурации (setpci).

# Required:    no
# Recommended: hwdata (runtime)
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# Запретим установку файла pci.ids, т.к. он устанавливается с пакетом hwdata.
sed -r '/INSTALL/{/PCI_IDS|update-pciids /d; s/update-pciids.8//}' \
    -i Makefile

make PREFIX=/usr                \
     SHAREDIR=/usr/share/hwdata \
     SHARED=yes || exit 1

# Пакет не содержит набора тестов.

make PREFIX=/usr                \
     SHAREDIR=/usr/share/hwdata \
     SHARED=yes                 \
     DESTDIR="${TMP_DIR}" install install-lib

chmod -v 755 "${TMP_DIR}/usr/lib/libpci.so"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (PCI utilities)
#
# 'lspci' displays detailed information about all PCI buses and devices in the
# system, replacing the original /proc/pci interface. 'setpci' allows reading
# from and writing to PCI device configuration registers. For example, you can
# adjust the latency timers with it.
#
# Home page: https://mj.ucw.cz/sw/${PRGNAME}/
# Download:  https://mirror.yandex.ru/pub/software/utils/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
