#! /bin/bash

PRGNAME="acpid"

### acpid (Advanced Configuration and Power Interface event daemon)
# Advanced Configuration and Power Interface (ACPI) является стандартом для
# управления питанием. Пакет содержит acpid (Advanced Configuration and Power
# Interface event daemon) - гибкий и расширяемый демон пользовательского
# пространства для доставки событий ACPI. Он прослушивает интерфейс netlink и,
# когда происходит событие, выполняет команды для обработки этих событий.
# Выполняемые команды настраиваются через набор файлов конфигурации, которые
# могут быть написаны пользователем.

# Required:    no
# Recommended: no
# Optional:    no

### Конфигурация ядра
# ACPI должен быть вкомпилен в ядро
#    CONFIG_ACPI=y

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
EVENTS="/etc/acpi/events"
mkdir -pv "${TMP_DIR}"{"${EVENTS}","${DOCS}"}

./configure       \
    --prefix=/usr \
    --docdir="${DOCS}" || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

cp -vr samples "${TMP_DIR}${DOCS}"

### Конфигурация
# будем кидать машину в suspend при закрытии крышки ноутбука
# (требуется утилита pm-suspend - пакет pm-utils)
cat << EOF > "${TMP_DIR}${EVENTS}/lid"
# suspend the system when the laptop lid is closed
event=button/lid
action=/etc/acpi/suspend.sh %e
EOF

cat << EOF > "${TMP_DIR}/etc/acpi/suspend.sh"
#!/bin/sh

###
# suspend the system when the laptop lid is closed
###

# 'pm-utils' package required
! command -v pm-suspend &>/dev/null && exit 0

# laptop lid state (open/close)
# cat /proc/acpi/button/lid/*/state
/bin/grep -q open /proc/acpi/button/lid/*/state && exit 0
/usr/sbin/pm-suspend
EOF

chmod 755 "${TMP_DIR}/etc/acpi/suspend.sh"

# для автозапуска acpid при загрузке системы установим скрипт инициализации
# /etc/rc.d/init.d/acpid
(
    cd "${ROOT}/blfs-bootscripts" || exit 1
    make install-acpid DESTDIR="${TMP_DIR}"
)

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (ACPI daemon)
#
# The acpid (Advanced Configuration and Power Interface event daemon) is a
# completely flexible, totally extensible daemon for delivering ACPI events. It
# listens on netlink interface and when an event occurs, executes programs to
# handle the event. The programs it executes are configured through a set of
# configuration files, which can be dropped into place by packages or by the
# user.
#
# Home page: https://sourceforge.net/projects/${PRGNAME}2/
# Download:  https://downloads.sourceforge.net/${PRGNAME}2/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
