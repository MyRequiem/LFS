#! /bin/bash

PRGNAME="util-linux"

### Util-linux
# Содержит различные утилиты для обработки файловых систем, консолей, разделов,
# сообщений и т.д.

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter06/util-linux.html

# Home page: http://freecode.com/projects/util-linux
# Download:  https://www.kernel.org/pub/linux/utils/util-linux/v2.34/util-linux-2.34.tar.xz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

# FHS рекомендует использовать каталог /var/lib/hwclock вместо /etc для файла
# adjtime, в котором хранится величина отклонения аппаратных часов
mkdir -pv /var/lib/hwclock

./configure ADJTIME_PATH=/var/lib/hwclock/adjtime   \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" \
    --disable-chfn-chsh                             \
    --disable-login                                 \
    --disable-nologin                               \
    --disable-su                                    \
    --disable-setpriv                               \
    --disable-runuser                               \
    --disable-pylibmount                            \
    --disable-static                                \
    --without-python                                \
    --without-systemd                               \
    --without-systemdsystemunitdir || exit 1

make || exit 1
# запуск набора тестов от имени пользователя root может быть не безопасным для
# системы, поэтому будем запускать от имени пользователя nobody. Для запуска
# тестов в конфигурации ядра должна быть установлена опция CONFIG_SCSI_DEBUG=m
bash tests/run.sh --srcdir="${PWD}" --builddir="${PWD}"
chown -Rv nobody .
su nobody -s /bin/bash -c "PATH=${PATH} make -k check"
chown -Rv root:root .
# устанавливаем пакет
make install

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/var/lib/hwclock"
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a huge collection of essential utilities)
#
# The Util-linux package contains miscellaneous utility programs that are
# essential to run a Linux system. Among them are utilities for handling file
# systems, consoles, partitions, and messages.
#
# Home page: http://freecode.com/projects/${PRGNAME}
# Download:  https://www.kernel.org/pub/linux/utils/${PRGNAME}/v${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
