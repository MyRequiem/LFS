#! /bin/bash

PRGNAME="findutils"

### Findutils (utilities to locate files)
# Программа для поиска файлов в файловой системе (find), в базе данных имен
# файлов (locate), для обновления этой базы данных (updatedb) и утилита для
# применения заданной команды к списку файлов (xargs)

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/bin"

# задает расположение базы данных locate в соответствии со стандартом FHS
#    --localstatedir=/var/lib/locate
./configure       \
    --prefix=/usr \
    --localstatedir=/var/lib/locate || exit 1

make || make -j1 || exit 1

# тесты запускаем от пользователя tester
# chown -Rv tester .
# su tester -c "PATH=${PATH} make check"
# chown -Rv root:root .

make install DESTDIR="${TMP_DIR}"

# некоторые из сценариев в пакете LFS-Bootscripts используют утилиту find.
# Каталог /usr/bin может быть недоступен на ранних стадиях загрузки системы,
# поэтому переместим утилиту find в /bin
mv -v "${TMP_DIR}/usr/bin/find" "${TMP_DIR}/bin"
sed -i 's|find:=${BINDIR}|find:=/bin|' "${TMP_DIR}/usr/bin/updatedb"

rm -f "${TMP_DIR}/usr/share/info/dir"

/bin/cp -vR "${TMP_DIR}"/* /

# система документации Info использует простые текстовые файлы в
# /usr/share/info/, а список этих файлов хранится в файле /usr/share/info/dir
# который мы обновим
cd /usr/share/info || exit 1
rm -fv dir
for FILE in *; do
    install-info "${FILE}" dir 2>/dev/null
done

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
# Download:  http://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
