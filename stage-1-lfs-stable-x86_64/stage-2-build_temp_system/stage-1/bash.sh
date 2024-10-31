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
./configure                              \
    --prefix=/usr                        \
    --build="$(sh support/config.guess)" \
    --host="${LFS_TGT}"                  \
    --without-bash-malloc                \
    bash_cv_strtold_broken=no || exit 1

make || make -j1 || exit 1
make DESTDIR="${LFS}" install

# создадим ссылку sh -> bash в ${LFS}/bin/
ln -svf bash "${LFS}/bin/sh"
