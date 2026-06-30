#! /bin/bash

PRGNAME="unixodbc"
ARCH_NAME="unixODBC"

### unixODBC (Open DataBase Connectivity for Unix platforms)
# Стандартная прослойка, позволяющая программам в Linux общаться с самыми
# разными базами данных по единому протоколу. Она избавляет разработчиков от
# необходимости писать отдельный код для каждого типа хранилища данных.

# Required:    no
# Recommended: no
# Optional:    minisql    (https://hughestech.com.au/products/msql/)

### Конфигурация
#    /etc/unixODBC/*

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

autoreconf -fiv || exit 1
./configure       \
    --prefix=/usr \
    --sysconfdir=/etc/unixODBC || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Open DataBase Connectivity for Unix platforms)
#
# The unixODBC package is an Open Source ODBC (Open DataBase Connectivity)
# sub-system and an ODBC SDK for Linux, Mac OSX, and UNIX. ODBC is an open
# specification for providing application developers with a predictable API
# with which to access data sources. Data sources include optional SQL Servers
# and any data source with an ODBC Driver. unixODBC contains the following
# components used to assist with the manipulation of ODBC data sources: a
# driver manager, an installer library and command line tool, command line
# tools to help install a driver and work with SQL, drivers and driver setup
# libraries.
#
# Home page: https://www.${PRGNAME}.org/
# Download:  https://github.com/lurcher/${ARCH_NAME}/archive/v${VERSION}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
