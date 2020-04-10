#! /bin/bash

PRGNAME="e2fsprogs"

### E2fsprogs (ext2 and ext3 filesystems utilities)
# утилиты для работы с файловой системой ext2, а также поддерживает
# журналируемые файловые системы ext3 и ext4

# http://www.linuxfromscratch.org/lfs/view/stable/chapter06/e2fsprogs.html

# Home page: http://e2fsprogs.sourceforge.net/
# Download:  https://downloads.sourceforge.net/project/e2fsprogs/e2fsprogs/v1.45.5/e2fsprogs-1.45.5.tar.gz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}config_file_processing.sh"             || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# документация E2fsprogs рекомендует проводить сборку в отдельном подкаталоге
# дерева исходников
mkdir build
cd build || exit 1

# некоторые программы этого пакета, например e2fsck, должны быть доступны на
# ранних стадиях загрузки системы, но каталоги /usr/{bin,lib} куда
# устанавливаются такие программы по умолчанию, в этот момент могут быть еще не
# доступны. Поэтому установим их в /bin и /lib
#    --with-root-prefix=""
#    --bindir=/bin
# создаем общие библиотеки, которые используют некоторые программы в этом
# пакете
#    --enable-elf-shlibs
# не будем собирать и устанавливать libuuid, библиотеки libblkid, демон uuidd и
# оболочку fsck, т.к. в пакете Util-Linux содержатся более свежие версии этих
# утилит
#    --disable-libblkid
#    --disable-libuuid
#    --disable-uuidd
#    --disable-fsck
../configure              \
    --prefix=/usr         \
    --bindir=/bin         \
    --with-root-prefix="" \
    --enable-elf-shlibs   \
    --disable-libblkid    \
    --disable-libuuid     \
    --disable-uuidd       \
    --disable-fsck || exit 1

make || exit 1
make check

# бэкапим конфиги /etc/e2scrub.conf и /etc/mke2fs.conf перед установкой пакета,
# если они существует
E2SCRUB_CONF="/etc/e2scrub.conf"
if [ -f "${E2SCRUB_CONF}" ]; then
    mv "${E2SCRUB_CONF}" "${E2SCRUB_CONF}.old"
fi

MKE2FS_CONF="/etc/mke2fs.conf"
if [ -f "${MKE2FS_CONF}" ]; then
    mv "${MKE2FS_CONF}" "${MKE2FS_CONF}.old"
fi

make install
make install DESTDIR="${TMP_DIR}"

config_file_processing "${E2SCRUB_CONF}"
config_file_processing "${MKE2FS_CONF}"

# сделаем установленные статические библиотеки *.a доступными для записи, чтобы
# позже можно было удалить из них отладочную информацию
chmod -v u+w /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a
chmod -v u+w "${TMP_DIR}/usr/lib"/{libcom_err,libe2p,libext2fs,libss}.a

# пакет устанавливает сжатый файл libext2fs.info.gz, но не обновляет индекс
# info-системы, который находится в файле /usr/share/info/dir. Распакуем архив,
# а затем обновим индекс info-системы
INFO="/usr/share/info/libext2fs.info"
gunzip -v "${INFO}.gz"
gunzip -v "${TMP_DIR}${INFO}.gz"
install-info --dir-file=/usr/share/info/dir "${INFO}"
install-info --dir-file="${TMP_DIR}/usr/share/info/dir" "${TMP_DIR}${INFO}"

# установим документацию в систему info (/usr/share/info/)
makeinfo -o doc/com_err.info ../lib/et/com_err.texinfo
install  -v -m644 doc/com_err.info /usr/share/info
install  -v -m644 doc/com_err.info "${TMP_DIR}/usr/share/info"
install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info
install-info --dir-file="${TMP_DIR}/usr/share/info/dir" \
    "${TMP_DIR}/usr/share/info/com_err.info"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (ext2 and ext3 filesystems utilities)
#
# The E2fsprogs package contains the utilities for handling the ext2 file
# system. It also supports the ext3 and ext4 journaling file systems.
#
# Home page: http://e2fsprogs.sourceforge.net/
# Download:  https://downloads.sourceforge.net/project/${PRGNAME}/${PRGNAME}/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#            http://kernel.org/pub/linux/kernel/people/tytso/${PRGNAME}/
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
