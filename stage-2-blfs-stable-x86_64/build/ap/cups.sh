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
#              cups-filters
# Recommended: colord
#              dbus
#              libusb
#              linux-pam
#              xdg-utils
# Optional:    avahi
#              libpaper
#              mit-kerberos-v5
#              openjdk
#              php
#              python2
#              gutenprint
#              hplip (для принтеров HP - https://developers.hp.com/hp-linux-imaging-and-printing)

### Конфигурация ядра
#    CONFIG_USB_SUPPORT=y
#    CONFIG_USB_OHCI_HCD=y|m
#    CONFIG_USB_UHCI_HCD=y|m
#    CONFIG_USB_PRINTER=y|m

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

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# создадим группу lpadmin и пользователя lp (группа lp уже создана с пакетом
# 'main-directory-tree')
! grep -qE "^lpadmin:" /etc/group  && \
    groupadd -g 19 lpadmin

! grep -qE "^lp:" /etc/passwd &&    \
    useradd -c "Print Service User" \
            -d /var/spool/cups      \
            -g lp                   \
            -s /bin/false           \
            -u 9 lp

# изменим браузер по умолчанию на Firefox, который будет использоваться для
# доступа к веб-интерфейсу Cups (к серверу Cups обычно можно подключиться по
# адресу http://localhost:631)
sed -i 's#@CUPS_HTMLVIEW@#firefox#' desktop/cups.desktop.in || exit 1

# исправим ошибку, вызванную изменениями в glibc >=2.30 в API пользовательского
# пространства для сокетов
sed -i '/stat.h/a #include <asm-generic/ioctls.h>' tools/ipptool.c || exit 1

LIBPAPER="--disable-libpaper"
command -v paperconf &>/dev/null && LIBPAPER="--enable-libpaper"

# устанавливаем поставляемый с пакетом загрузочный скрипт в /tmp вместо
# /etc/rc.d, а замем его удалим. Позже мы установим свой загрузочный скрипт в
# /etc/rc.d
#    --with-rcdir=/tmp/cupsinit
#
# используем именно gcc, а не clang (использование clang почти удваивается
# время сборки)
CC=gcc CXX=g++                   \
./configure                      \
    --libdir=/usr/lib            \
    --disable-systemd            \
    "${LIBPAPER}"                \
    --with-rcdir=/tmp/cupsinit   \
    --with-system-groups=lpadmin \
    --with-docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1

# тесты нужно проводит в графической среде
# LC_ALL=C make -k check

make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/tmp"

mv "${TMP_DIR}/var/run" "${TMP_DIR}/"

# создадим базовый файл конфигурации клиента cups
CLIENT_CONF="/etc/cups/client.conf"
echo "ServerName /run/cups/cups.sock" > "${TMP_DIR}${CLIENT_CONF}"

# создадим/обновим кэш иконок /usr/share/icons/hicolor/icon-theme.cache
gtk-update-icon-cache -qtf /usr/share/icons/hicolor

# установим загрузочный скрипт для запуска cups при старте системы
(
    cd "${ROOT}/blfs-bootscripts" || exit 1
    make install-cups DESTDIR="${TMP_DIR}"
)

if [ -f "${CLIENT_CONF}" ]; then
    mv "${CLIENT_CONF}" "${CLIENT_CONF}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${CLIENT_CONF}"

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
# Download:  https://github.com/apple/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}-source.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
