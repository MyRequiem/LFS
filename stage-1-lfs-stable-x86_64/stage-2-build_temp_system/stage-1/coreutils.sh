#! /bin/bash

PRGNAME="coreutils"

### Coreutils
# Утилиты для отображения и настройки основных характеристик системы: basename,
# cat, chmod, chown, chroot, cp, cut, date и т.д.

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

# собирать утилиту hostname - ее создание отключено по умолчанию, но она нужна
# для тестов при сборке Perl
#    --enable-install-program=hostname
./configure                             \
    --prefix=/usr                       \
    --host="${LFS_TGT}"                 \
    --build="$(build-aux/config.guess)" \
    --enable-install-program=hostname   \
    --enable-no-install-program=kill,uptime || exit 1

make || make -j1 || exit 1
make DESTDIR="${LFS}" install

# утилита chroot в /usr/sbin
mv -v "${LFS}/usr/bin/chroot" "${LFS}/usr/sbin"

# переместим man-страницу из man1 в man8
mkdir -pv "${LFS}/usr/share/man/man8"
mv -v "${LFS}/usr/share/man/man1/chroot.1" "${LFS}/usr/share/man/man8/chroot.8"
sed -i 's/"1"/"8"/' "${LFS}/usr/share/man/man8/chroot.8"
