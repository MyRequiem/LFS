#! /bin/bash

PRGNAME="bash"

### Bash
# Bourne-Again SHell

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter05/bash.html

# Home page: http://www.gnu.org/software/bash/
# Download:  http://ftp.gnu.org/gnu/bash/bash-5.0.tar.gz

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

# опция отключает использование функции выделения памяти (malloc) Bash,
# которая, как известно, вызывает ошибки сегментации. Теперь Bash будет
# использовать функции malloc из Glibc, которые более стабильны.
#    --without-bash-malloc
./configure         \
    --prefix=/tools \
    --without-bash-malloc || exit 1

make || make -j1 || exit 1
make tests
make install

# создадим символическую ссылку в /tools/bin sh -> bash
ln -sv bash /tools/bin/sh
