#! /bin/bash

PRGNAME="bash"

### Bash
# Bourne-Again SHell

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

# опция отключает использование функции выделения памяти (malloc) Bash,
# которая, как известно, вызывает ошибки сегментации. Теперь Bash будет
# использовать функции malloc из Glibc, которые более стабильны.
#    --without-bash-malloc
./configure                           \
    --prefix=/usr                     \
    --host="${LFS_TGT}"               \
    --without-bash-malloc             \
    --build="$(support/config.guess)" \
    --docdir="/usr/share/doc/bash-${VERSION}" || exit 1

make || make -j1 || exit 1
make install DESTDIR="${LFS}"

# переместим исполняемый файл из /mnt/lfs/usr/bin в /mnt/lfs/bin
mv "${LFS}/usr/bin/bash" "${LFS}/bin/bash"

# создадим ссылку sh -> bash в /bin/
ln -svf bash "${LFS}/bin/sh"
