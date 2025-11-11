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
# Optional:    elogind

### Конфигурация ядра
# ACPI должен быть вкомпилен в ядро
#    CONFIG_ACPI=y

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
EVENTS="/etc/acpi/events"
mkdir -pv "${TMP_DIR}${EVENTS}"

./configure       \
    --prefix=/usr \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share/doc"

### Конфигурация
# будем кидать машину в suspend при закрытии крышки ноутбука
cat << EOF > "${TMP_DIR}${EVENTS}/lid"
# Suspend the system when the laptop lid is closed
event=button/lid LID close
action=/etc/acpi/suspend.sh
EOF

cat << EOF > "${TMP_DIR}/etc/acpi/suspend.sh"
#!/bin/sh

# Suspend the system when the laptop lid is closed (elogind package required)
command -v loginctl &>/dev/null && loginctl suspend
EOF

chmod 755 "${TMP_DIR}/etc/acpi/suspend.sh"

# отключим обработку по умолчанию события закрытия крышки ноутбука модулем
# elogind, когда система работает от батареи и не подключена к внешнему
# монитору, чтобы избежать конфликта
LOGIND_CONF_D="/etc/elogind/logind.conf.d"
mkdir -pv "${TMP_DIR}${LOGIND_CONF_D}"
echo HandleLidSwitch=ignore > "${TMP_DIR}${LOGIND_CONF_D}/acpi.conf"

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
