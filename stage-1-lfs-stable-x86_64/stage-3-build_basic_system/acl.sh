#! /bin/bash

PRGNAME="acl"

### Acl (tools for using POSIX Access Control Lists)
# Содержит утилиты для управления контроля доступа, которые используются для
# определения прав доступа к файлам и каталогам

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/lib"

./configure               \
    --prefix=/usr         \
    --bindir=/bin         \
    --disable-static      \
    --libexecdir=/usr/lib \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || make -j1 || exit 1

# тесты Acl должны выполняться в файловой системе, которая поддерживает
# контроль доступа после того, как был собран пакет Coreutils с библиотеками
# Acl. На данный момент Coreutils еще не установлен, поэтому тесты мы
# пропускаем

make install DESTDIR="${TMP_DIR}"

# библиотеку необходимо переместить из /usr/lib в /lib
mv -v "${TMP_DIR}/usr/lib"/libacl.so.* "${TMP_DIR}/lib"

# воссоздадим ссылку libacl.so в /usr/lib
#    libacl.so -> ../../lib/libacl.so.x.x.xxxx
(
    cd "${TMP_DIR}/usr/lib" || exit 1
    ln -sfv "../../lib/$(readlink libacl.so)" libacl.so
)

/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (tools for using POSIX Access Control Lists)
#
# This package contains a set of tools and libraries for manipulating POSIX
# Access Control Lists. POSIX Access Control Lists (defined in POSIX 1003.1e
# draft standard 17) are used to define more fine-grained discretionary access
# rights for files and directories.
#
# Home page: http://savannah.nongnu.org/projects/${PRGNAME}
# Download:  http://download.savannah.gnu.org/releases/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
