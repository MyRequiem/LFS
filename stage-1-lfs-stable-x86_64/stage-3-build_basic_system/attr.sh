#! /bin/bash

PRGNAME="attr"

### Attr (tools for using extended attributes on filesystems)
# Утилиты для управления расширенными атрибутами объектов файловой системы

# http://www.linuxfromscratch.org/lfs/view/stable/chapter08/attr.html

# Home page: https://savannah.nongnu.org/projects/attr

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}config_file_processing.sh"             || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/lib"

./configure           \
    --prefix=/usr     \
    --bindir=/bin     \
    --disable-static  \
    --sysconfdir=/etc \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || make -j1 || exit 1

# тесты должны выполняться в файловой системе, которая поддерживает расширенные
# атрибуты, такие как ext2, ext3 или ext4
# make check

# устанавливаем пакет
make install DESTDIR="${TMP_DIR}"

# библиотеку необходимо переместить из /usr/lib в /lib
mv -v "${TMP_DIR}/usr/lib/libattr.so."* "${TMP_DIR}/lib/"

# воссоздадим ссылку libattr.so в /usr/lib
#    libattr.so -> ../../lib/libattr.so.x.x.xxxx
(
    cd "${TMP_DIR}/usr/lib" || exit 1
    ln -sfv "../../lib/$(readlink libattr.so)" libattr.so
)

# бэкапим конфиг /etc/xattr.conf перед установкой пакета, если он существует
XATTR_CONFIG="/etc/xattr.conf"
if [ -f "${XATTR_CONFIG}" ]; then
    mv "${XATTR_CONFIG}" "${XATTR_CONFIG}.old"
fi

/bin/cp -vR "${TMP_DIR}"/* /

config_file_processing "${XATTR_CONFIG}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (tools for using extended attributes on filesystems)
#
# This package contains a set of tools for manipulating extended attributes
# (name:value pairs associated permanently with files and directories) on
# filesystem objects, and the library and header files needed to develop
# programs which make use of extended attributes. Extended attributes are used
# to provide additional functionality to a filesystem. For example, Access
# Control Lists (ACLs) are implemented using extended attributes.
#
# Home page: https://savannah.nongnu.org/projects/${PRGNAME}
# Download:  http://download.savannah.gnu.org/releases/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
