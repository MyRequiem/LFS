#! /bin/bash

PRGNAME="util-linux"

### Util-linux
# Содержит различные утилиты для обработки файловых систем, консолей, разделов,
# сообщений и т.д.

# http://www.linuxfromscratch.org/lfs/view/stable/chapter07/util-linux.html

# Home page: http://freecode.com/projects/util-linux

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

# создадим каталог для хранения данных утилиты hwclock
mkdir -pv /var/lib/hwclock

# устанавливаем местоположение файла для записи информации об аппаратных часах
# в соответствии с FHS
#    ADJTIME_PATH=/var/lib/hwclock/adjtime
# предотвращают появление предупреждений о создании компонентов, для которых
# отсутствуют зависимости в нашей временной системе
#    --disable-*
# отключаем создание python bindings
#    --without-python
./configure                               \
    ADJTIME_PATH=/var/lib/hwclock/adjtime \
    --prefix=/usr                         \
    --disable-chfn-chsh                   \
    --disable-login                       \
    --disable-nologin                     \
    --disable-su                          \
    --disable-setpriv                     \
    --disable-runuser                     \
    --disable-pylibmount                  \
    --disable-static                      \
    --without-python                      \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || make -j1 || exit 1
make install
