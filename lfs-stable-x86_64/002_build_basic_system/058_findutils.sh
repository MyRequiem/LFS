#! /bin/bash

PRGNAME="findutils"

### Findutils
# Пакет содержит программы для поиска файлов

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter06/findutils.html

# Home page: http://www.gnu.org/software/findutils/
# Download:  http://ftp.gnu.org/gnu/findutils/findutils-4.6.0.tar.gz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

# отменим тест, который на некоторых машинах может бесконечно зацикливаться
sed -i 's/test-lock..EXEEXT.//' tests/Makefile.in

# внесем исправления, необходимые для glibc-2.28 и более поздних версий
sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' gl/lib/*.c
sed -i '/unistd/a #include <sys/sysmacros.h>' gl/lib/mountlist.c
echo "#define _IO_IN_BACKUP 0x100" >> gl/lib/stdio-impl.h

# изменяет расположение базы данных locate в /var/lib/locate, что соответствует
# стандарту FHS
#    --localstatedir=/var/lib/locate
./configure       \
    --prefix=/usr \
    --localstatedir=/var/lib/locate || exit 1

make || exit 1
make check
make install

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/bin"
make install DESTDIR="${TMP_DIR}"

# некоторые из сценариев в пакете LFS-Bootscripts используют утилиту find.
# Каталог /usr/bin может быть недоступен на ранних стадиях загрузки системы,
# поэтому переместим утилиту find в /bin
mv -v /usr/bin/find /bin
sed -i 's|find:=${BINDIR}|find:=/bin|' /usr/bin/updatedb
mv -v "${TMP_DIR}/usr/bin/find" "${TMP_DIR}/bin"
sed -i 's|find:=${BINDIR}|find:=/bin|' "${TMP_DIR}/usr/bin/updatedb"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (utilities to locate files)
#
# The Findutils package contains programs to find files (find, locate,
# updatedb, xargs). These programs are provided to recursively search through a
# directory tree and to create, maintain, and search a database (often faster
# than the recursive find, but unreliable if the database has not been recently
# updated). The find and xargs implementations comply with POSIX 1003.2. They
# also support some additional options, some borrowed from Unix and some unique
# to GNU.
#
# Home page: http://www.gnu.org/software/${PRGNAME}/
# Download:  http://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
