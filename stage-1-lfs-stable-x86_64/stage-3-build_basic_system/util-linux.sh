#! /bin/bash

PRGNAME="util-linux"

### Util-linux (a huge collection of essential utilities)
# Служебные утилиты для работы с файловыми системами, консолями, разделами
# жесткого диска, системными сообщениями и др.

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/var/lib/hwclock"

# FHS рекомендует использовать каталог /var/lib/hwclock вместо /etc для файла
# adjtime, в котором хранится величина отклонения аппаратных часов
mkdir -pv /var/lib/hwclock

./configure                               \
    ADJTIME_PATH=/var/lib/hwclock/adjtime \
    --disable-chfn-chsh                   \
    --disable-login                       \
    --disable-nologin                     \
    --disable-su                          \
    --disable-setpriv                     \
    --disable-runuser                     \
    --disable-pylibmount                  \
    --disable-static                      \
    --without-python                      \
    --without-systemd                     \
    --without-systemdsystemunitdir        \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || make -j1 || exit 1

# NOTE:
# для запуска тестов в конфигурации ядра хоста должен быть установлен параметр
# CONFIG_SCSI_DEBUG как модуль
#
# запуск набора тестов от имени пользователя root может быть не безопасным для
# системы, поэтому будем запускать от имени пользователя tester
# chown -Rv tester .
# su tester -c "make -k check"
# chown -Rv root:root .

make install DESTDIR="${TMP_DIR}"

/bin/cp -vR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a huge collection of essential utilities)
#
# The Util-linux package contains miscellaneous utility programs that are
# essential to run a Linux system. Among them are utilities for handling file
# systems, consoles, partitions, and messages.
#
# Home page: http://freecode.com/projects/${PRGNAME}
# Download:  https://www.kernel.org/pub/linux/utils/${PRGNAME}/v${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
