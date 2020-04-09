#! /bin/bash

if [[ "$(id -u)" != "0" ]]; then
    echo "Only superuser (root) can run this script"
    exit 1
fi

# мы в chroot окружении?
ID1="$(awk '$5=="/" {print $1}' < /proc/1/mountinfo)"
ID2="$(awk '$5=="/" {print $1}' < /proc/$$/mountinfo)"
if [[ "${ID1}" == "${ID2}" ]]; then
    echo "You must enter chroot environment."
    echo "Run 003_entering_chroot.sh script in this directory."
    exit 1
fi

# было установлено несколько статических библиотек, которые создавались только
# чтобы удовлетворить регрессионные тесты в нескольких пакетах. Это библиотеки
# от binutils, bzip2, e2fsprogs, flex, libtool и zlib. Желательно их удалить
rm -f /usr/lib/lib{bfd,opcodes}.a
rm -f /usr/lib/libbz2.a
rm -f /usr/lib/lib{com_err,e2p,ext2fs,ss}.a
rm -f /usr/lib/libltdl.a
rm -f /usr/lib/libfl.a
rm -f /usr/lib/libz.a

# удалим пути к удаленным файлам из списков установленных пакетами файлов в
# /var/log/packages/
PKG_FILES="$(find /var/log/packages -type f)"
for FILE in ${PKG_FILES}; do
    sed -i 's/^\/usr\/lib\/libbfd\.a$//'     "${FILE}"
    sed -i 's/^\/usr\/lib\/libopcodes\.a$//' "${FILE}"
    sed -i 's/^\/usr\/lib\/libbz2\.a$//'     "${FILE}"
    sed -i 's/^\/usr\/lib\/libcom_err\.a$//' "${FILE}"
    sed -i 's/^\/usr\/lib\/libe2p\.a$//'     "${FILE}"
    sed -i 's/^\/usr\/lib\/libext2fs\.a$//'  "${FILE}"
    sed -i 's/^\/usr\/lib\/libss\.a$//'      "${FILE}"
    sed -i 's/^\/usr\/lib\/libltdl\.a$//'    "${FILE}"
    sed -i 's/^\/usr\/lib\/libfl\.a$//'      "${FILE}"
    sed -i 's/^\/usr\/lib\/libz\.a$//'       "${FILE}"
    sed -i '/^$/d'                           "${FILE}"
done
