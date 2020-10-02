#! /bin/bash

PRGNAME="coreutils"

### Coreutils
# Утилиты для отображения и настройки основных характеристик системы: basename,
# cat, chmod, chown, chroot, cp, cut, date и т.д.

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

# собирать утилиту hostname - ее создание отключено по умолчанию
#    --enable-install-program=hostname
./configure                             \
    --prefix=/usr                       \
    --host="${LFS_TGT}"                 \
    --build="$(build-aux/config.guess)" \
    --enable-install-program=hostname   \
    --enable-no-install-program=kill,uptime || exit 1

make || make -j1 || exit 1
make install DESTDIR="${LFS}"

# переместим некоторые утилиты в их ожидаемое местоположение (для их запуска в
# нашей временной среде в этом нет необходимости, но мы должны это сделать,
# т.к. некоторые программы жестко кодируют расположение исполняемых файлов)
BIN="${LFS}/bin"
USBIN="${LFS}/usr/sbin"
mv -v "${LFS}/usr/bin"/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} "${BIN}"
mv -v "${LFS}/usr/bin"/{false,ln,ls,mkdir,mknod,mv,pwd,rm}        "${BIN}"
mv -v "${LFS}/usr/bin"/{rmdir,stty,sync,true,uname}               "${BIN}"
mv -v "${LFS}/usr/bin"/{head,nice,sleep,touch}                    "${BIN}"
mv -v "${LFS}/usr/bin/chroot"                                     "${USBIN}"

MAN="${LFS}/usr/share/man"
mkdir -pv "${MAN}/man8"
mv -v "${MAN}/man1/chroot.1" "${MAN}/man8/chroot.8"
sed -i 's/"1"/"8"/' "${MAN}/man8/chroot.8"
