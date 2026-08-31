#! /bin/bash

PRGNAME="m4"

### M4
# Мощный макропроцессор, используемый другими инструментами разработки для
# автоматической генерации программного кода.

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

# Начиная с glibc-2.44, добавлены функции posix_spawn.*chdir. При
# кросс-компиляции старая версия Gnulib в пакете M4 не может их правильно
# определить, из-за чего сборка зависает. Принудительно передаем правильные
# ответы через config.site.
cat > "${LFS}/usr/share/config.site" << EOF
ac_cv_func_posix_spawn_file_actions_addchdir=yes
ac_cv_func_posix_spawn_file_actions_addfchdir=yes
EOF

export CONFIG_SITE="${LFS}/usr/share/config.site"
./configure             \
    --prefix=/usr       \
    --host="${LFS_TGT}" \
    --build="$(build-aux/config.guess)" || exit 1

make || make -j1 || exit 1
make DESTDIR="${LFS}" install || exit 1
rm -f "${LFS}/usr/share/config.site"
