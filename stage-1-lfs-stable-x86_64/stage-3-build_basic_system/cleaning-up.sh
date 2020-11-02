#! /bin/bash

source "${ROOT}check_environment.sh" || exit 1

# временные инструменты /tools нам больше не понадобятся и их можно удалить
rm -rf /tools

# было установлено несколько статических библиотек, которые создавались только
# чтобы удовлетворить регрессионные тесты в нескольких пакетах. Это библиотеки
# от binutils, bzip2, e2fsprogs, flex, libtool и zlib. Желательно их удалить
rm -fv /usr/lib/lib{bfd,opcodes}.a
rm -fv /usr/lib/libctf{,-nobfd}.a
rm -fv /usr/lib/libbz2.a
rm -fv /usr/lib/lib{com_err,e2p,ext2fs,ss}.a
rm -fv /usr/lib/libltdl.a
rm -fv /usr/lib/libfl.a
rm -fv /usr/lib/libz.a

# удалим пути к удаленным файлам из списков установленных пакетами файлов в
# /var/log/packages/
PKG_FILES="$(find /var/log/packages -type f)"
for FILE in ${PKG_FILES}; do
    sed -i 's/^\/usr\/lib\/libbfd\.a$//'       "${FILE}"
    sed -i 's/^\/usr\/lib\/libopcodes\.a$//'   "${FILE}"
    sed -i 's/^\/usr\/lib\/libctf\.a$//'       "${FILE}"
    sed -i 's/^\/usr\/lib\/libctf-nobfd\.a$//' "${FILE}"
    sed -i 's/^\/usr\/lib\/libbz2\.a$//'       "${FILE}"
    sed -i 's/^\/usr\/lib\/libcom_err\.a$//'   "${FILE}"
    sed -i 's/^\/usr\/lib\/libe2p\.a$//'       "${FILE}"
    sed -i 's/^\/usr\/lib\/libext2fs\.a$//'    "${FILE}"
    sed -i 's/^\/usr\/lib\/libss\.a$//'        "${FILE}"
    sed -i 's/^\/usr\/lib\/libltdl\.a$//'      "${FILE}"
    sed -i 's/^\/usr\/lib\/libfl\.a$//'        "${FILE}"
    sed -i 's/^\/usr\/lib\/libz\.a$//'         "${FILE}"
    sed -i '/^$/d'                             "${FILE}"
done

# В каталогах /usr/lib и /usr/libexec находятся файлы с расширением .la Это
# текстовые libtool-архивы, которые полезны только при линковке со статическими
# библиотеками. Такие архивы не нужны и потенциально вредны при использовании
# динамических библиотек, особенно при использовании не автоматических систем
# сборки, поэтому удалим их
find /usr/lib /usr/libexec -name "*.la" -delete

# удалим созданного в
# stage-2-build_temp_system/stage-2/creating-essential-files-and-symlinks.sh
# временного пользователя tester
userdel -r tester
