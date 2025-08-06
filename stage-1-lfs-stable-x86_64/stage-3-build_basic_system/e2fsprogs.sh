#! /bin/bash

PRGNAME="e2fsprogs"

### E2fsprogs (ext2 and ext3 filesystems utilities)
# Пакет содержит утилиты для работы с файловой системой ext2, а также
# поддерживает журналируемые файловые системы ext3 и ext4

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# документация E2fsprogs рекомендует собирать пакет в отдельном каталоге
mkdir build
cd build || exit 1

# создаем общие библиотеки (shared), которые используются некоторыми
# программами в этом пакете
#    --enable-elf-shlibs
# не будем собирать и устанавливать libuuid, библиотеки libblkid, демон uuidd и
# оболочку fsck, т.к. в уже установленном пакете util-linux содержатся более
# свежие версии этих утилит
#    --disable-*
../configure              \
    --prefix=/usr         \
    --sysconfdir=/etc     \
    --enable-elf-shlibs   \
    --disable-libblkid    \
    --disable-libuuid     \
    --disable-uuidd       \
    --disable-fsck || exit 1

make || make -j1 || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

# удалим бесполезные статические библиотеки
rm -fv "${TMP_DIR}/usr/lib"/{libcom_err,libe2p,libext2fs,libss}.a

# пакет устанавливает сжатый libext2fs.info.gz, распакуем его
gunzip -v "${TMP_DIR}/usr/share/info/libext2fs.info.gz" || exit 1

# установим дополнительную документацию в систему info (/usr/share/info/)
makeinfo -o doc/com_err.info ../lib/et/com_err.texinfo
install -v -m644 doc/com_err.info "${TMP_DIR}/usr/share/info"

# некоторые утилиты, не входящие в LFS и BLFS, не могут распознать файловую
# систему ext4 с включенной функцией Metadata_csum_seed, поэтому удалим эту
# функцию из списка функций ext4 по умолчанию
sed 's/metadata_csum_seed,//' -i "${TMP_DIR}/etc/mke2fs.conf"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (ext2 and ext3 filesystems utilities)
#
# The E2fsprogs package contains the utilities for handling the ext2 file
# system. It also supports the ext3 and ext4 journaling file systems.
#
# Home page: https://e2fsprogs.sourceforge.net/
# Download:  https://downloads.sourceforge.net/project/${PRGNAME}/${PRGNAME}/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#            https://kernel.org/pub/linux/kernel/people/tytso/${PRGNAME}/
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
