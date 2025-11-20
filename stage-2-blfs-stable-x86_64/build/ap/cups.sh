#! /bin/bash

PRGNAME="cups"

### Cups (Common UNIX Printing System)
# Сервер печати для UNIX-подобных операционных систем. Компьютер с запущенным
# сервером CUPS представляет собой сетевой узел, который принимает задания на
# печать от клиентов, обрабатывает их и отправляет на соответствующий принтер.
#
# Состав CUPS:
#    - диспетчер печати
#    - планировщик
#    - система фильтрации, преобразующая данные печати в формат, понятный
#       принтеру
#    - Back-end - система, отправляющая данные на устройства печати

# Required:    gnutls
# Recommended: colord
#              dbus
#              libusb
#              linux-pam
#              xdg-utils
# Optional:    avahi
#              libpaper
#              php
#              python2          (https://www.python.org/downloads/release/python-2718/)
#              cups-filters
#              gutenprint
#              hplip            (для принтеров HP - https://developers.hp.com/hp-linux-imaging-and-printing)

### Конфигурация ядра
# Для USB принтеров
#    CONFIG_USB_SUPPORT=y
#    CONFIG_USB_OHCI_HCD=y|m
#    CONFIG_USB_UHCI_HCD=y|m
#    CONFIG_USB_PRINTER=y|m
# Для принтеров, подключаемых через параллельный порт
#    CONFIG_PARPORT=y|m
#    CONFIG_PARPORT_PC=y|m
#    CONFIG_PRINTER=y|m

### Конфиги
#    /etc/cups/*

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"      || exit 1
source "${ROOT}/config_file_processing.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${PRGNAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    cut -d - -f 2)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}-${VERSION}"*.tar.?z* || exit 1
cd "${PRGNAME}-${VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# создадим группу lpadmin и пользователя lp (группа lp уже создана с пакетом
# 'main-directory-tree')
! grep -qE "^lpadmin:" /etc/group  && \
    groupadd -g 19 lpadmin

! grep -qE "^lp:" /etc/passwd &&       \
    useradd -c "Print Service User"    \
            -d "/var/spool/${PRGNAME}" \
            -g lp                      \
            -s /bin/false              \
            -u 9 lp

# устанавливаем поставляемый с пакетом загрузочный скрипт в /tmp вместо
# /etc/rc.d, а затем его удалим. Позже мы установим свой загрузочный скрипт в
# /etc/rc.d
#    --with-rcdir=/tmp/cupsinit
./configure                      \
    --libdir=/usr/lib            \
    --with-rcdir=/tmp/cupsinit   \
    --with-rundir=/run/cups      \
    --with-system-groups=lpadmin \
    --disable-pam                \
    --with-docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1

# тесты нужно проводит в графической среде
# LC_ALL=C make -k check

make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}"/{tmp,var/run}

# создадим базовый файл конфигурации клиента cups
echo "ServerName /run/${PRGNAME}/${PRGNAME}.sock" > \
    "${TMP_DIR}/etc/${PRGNAME}/client.conf"

# установим загрузочный скрипт для запуска cups при старте системы
(
    cd "${ROOT}/blfs-bootscripts" || exit 1
    make install-cups DESTDIR="${TMP_DIR}"
)

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

command -v gtk-update-icon-cache &>/dev/null && \
    gtk-update-icon-cache -qtf /usr/share/icons/hicolor

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Common UNIX Printing System)
#
# The Common UNIX Printing System provides a portable printing layer for
# UNIX(R)-like operating systems. It has been developed by Easy Software
# Products to promote a standard printing solution for all UNIX vendors and
# users. CUPS uses the Internet Printing Protocol ("IPP") as the basis for
# managing print jobs and queues. The CUPS package includes System V and
# Berkeley command-line interfaces, a PostScript RIP package for supporting
# non-PostScript printer drivers, and tools for creating additional printer
# drivers and other CUPS services.
#
# Home page: https://openprinting.github.io/${PRGNAME}/
# Download:  https://github.com/OpenPrinting/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}-source.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
