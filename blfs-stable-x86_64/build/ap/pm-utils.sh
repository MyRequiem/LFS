#! /bin/bash

PRGNAME="pm-utils"

### pm-utils (Power Management Utilities)
# Инструменты командной строки для управления питанием и перевода машины в
# режимы suspend и hibernate.

# http://www.linuxfromscratch.org/blfs/view/stable/general/pm-utils.html

# Home page: http://pm-utils.freedesktop.org/
# Download:  https://pm-utils.freedesktop.org/releases/pm-utils-1.4.1.tar.gz

# Required: no
# Optional: xmlto (для создания ман-страниц)
#           hdparm
#           wireless-tools
#           ethtool (https://mirrors.edge.kernel.org/pub/software/network/ethtool/)
#           vbetool (http://ftp.de.debian.org/debian/pool/main/v/vbetool/)

### Конфигурация ядра
#    CONFIG_SUSPEND=y
#    CONFIG_HIBERNATION=y

### NOTE:
# Для использования режима hibernation в /boot/grub/grub.cfg ядру нужно
# передавать параметр resume=/dev/<swap_partition>. Swap раздел должен быть не
# меньше размера оперативной памяти.

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
MAN="/usr/share/man"
mkdir -pv "${TMP_DIR}${MAN}/"{man1,man8}

./configure           \
    --prefix=/usr     \
    --sysconfdir=/etc \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# пакет не имеет набора тестов
make install
make install DESTDIR="${TMP_DIR}"

XMLTO=""
command -v xmlto &>/dev/null && XMLTO="true"

# если пакет xmlto не установлен, то скопируем предварительно созданные
# man-страницы
if [ -z "${XMLTO}" ]; then
    install -v -m644 man/*.1 "${MAN}/man1"
    install -v -m644 man/*.8 "${MAN}/man8"

    install -v -m644 man/*.1 "${TMP_DIR}${MAN}/man1"
    install -v -m644 man/*.8 "${TMP_DIR}${MAN}/man8"

    ln -svf pm-action.8 ${MAN}/man8/pm-suspend.8
    ln -svf pm-action.8 ${MAN}/man8/pm-hibernate.8
    ln -svf pm-action.8 ${MAN}/man8/pm-suspend-hybrid.8

    (
        cd "${TMP_DIR}${MAN}/man8/" || exit 1
        ln -sv pm-action.8 pm-suspend.8
        ln -sv pm-action.8 pm-hibernate.8
        ln -sv pm-action.8 pm-suspend-hybrid.8
    )
fi

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Power Management Utilities)
#
# The Power Management Utilities provide simple shell command line tools to
# suspend and hibernate the computer. They can be used to run user supplied
# scripts on suspend and resume.
#
# Home page: http://${PRGNAME}.freedesktop.org/
# Download:  https://${PRGNAME}.freedesktop.org/releases/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
