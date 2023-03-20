#! /bin/bash

PRGNAME="pciutils"

### pciutils (PCI utilities)
# Пакет PCI Utils содержит набор утилит для вывода списка устройств PCI (lspci),
# проверки их состояния и настройки их регистров конфигурации (setpci)

# Required:    no
# Recommended: which                  (для корректной работы скрипта update-pciids)
#              curl или wget или lynx (для корректной работы скрипта update-pciids)
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
CRON_WEEKLY="/etc/cron.weekly"
mkdir -pv "${TMP_DIR}${CRON_WEEKLY}"

make            \
    PREFIX=/usr \
    SHARED=yes  \
    SHAREDIR=/usr/share/hwdata || exit 1

# пакет не содержит набора тестов

make                           \
    PREFIX=/usr                \
    SHARED=yes                 \
    SHAREDIR=/usr/share/hwdata \
    DESTDIR="${TMP_DIR}" install install-lib

chmod -v 755 "${TMP_DIR}/usr/lib/libpci.so"

### Конфигурация:
# Файл данных pci.ids находится в /usr/share/hwdata/ и должен периодически
# обновляться. Чтобы получить его текущую версию в состав пакета входит скрипт
# update-pciids, запуск которого настроим через fcron

UPDATE_PCIIDS="${TMP_DIR}${CRON_WEEKLY}/update-pciids.sh"
cat << EOF > "${UPDATE_PCIIDS}"
#!/bin/bash

/usr/sbin/update-pciids
EOF

chmod 754 "${UPDATE_PCIIDS}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
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
# Download:  https://mj.ucw.cz/download/linux/pci/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
