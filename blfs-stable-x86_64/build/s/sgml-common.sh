#! /bin/bash

PRGNAME="sgml-common"
VERSION="0.6.3"

### sgml-common
# Общий пакет SGML содержит утилиту 'install-catalog', необходимую для создания
# и поддержки централизованных каталогов SGML и XML

# http://www.linuxfromscratch.org/blfs/view/9.0/pst/sgml-common.html

# Home page: https://sourceware.org/ftp/docbook-tools/
# Download:  https://sourceware.org/ftp/docbook-tools/new-trials/SOURCES/sgml-common-0.6.3.tgz
# Patch:     http://www.linuxfromscratch.org/patches/blfs/9.0/sgml-common-0.6.3-manpage-1.patch

# Required: no
# Optional: no

ROOT="/"
source "${ROOT}check_environment.sh"      || exit 1
source "${ROOT}config_file_processing.sh" || exit 1

SOURCES="/sources"
BUILD_DIR="${SOURCES}/build"
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1
rm -rf "${PRGNAME}-${VERSION}"

tar xvf "${SOURCES}/${PRGNAME}-${VERSION}".tgz || exit 1
cd "${PRGNAME}-${VERSION}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

SGML_CONF="/etc/sgml/sgml.conf"
if [ -f "${SGML_CONF}" ]; then
    mv "${SGML_CONF}" "${SGML_CONF}.old"
fi

patch --verbose -Np1 -i "${SOURCES}/sgml-common-0.6.3-manpage-1.patch" || exit 1

autoreconf -f -i
./configure       \
    --prefix=/usr \
    --sysconfdir=/etc || exit 1

make || exit 1
# пакет не содержит набора тестов
# устанавливаем
make docdir=/usr/share/doc install
make docdir=/usr/share/doc install DESTDIR="${TMP_DIR}"

config_file_processing "${SGML_CONF}"

install-catalog --add /etc/sgml/sgml-ent.cat \
    /usr/share/sgml/sgml-iso-entities-8879.1986/catalog

install-catalog --add /etc/sgml/sgml-docbook.cat \
    /etc/sgml/sgml-ent.cat

cp -vR /etc/sgml/{catalog,sgml-docbook.cat,sgml-ent.cat} "${TMP_DIR}/etc/sgml/"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (SGML Common package)
#
# The SGML Common package contains install-catalog. This is useful for creating
# and maintaining centralized SGML catalogs.
#
# Home page: https://sourceware.org/ftp/docbook-tools/
# Download:  https://sourceware.org/ftp/docbook-tools/new-trials/SOURCES/${PRGNAME}-${VERSION}.tgz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
