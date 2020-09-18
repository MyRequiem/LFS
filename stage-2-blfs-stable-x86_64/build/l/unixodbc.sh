#! /bin/bash

PRGNAME="unixodbc"
ARCH_NAME="unixODBC"

### unixODBC (Independent Open DataBase Connectivity)
# Подсистема ODBC с открытым исходным кодом (Open DataBase Connectivity).
# Служит для предоставления разработчикам приложений API для доступа к
# источникам данных. Источники данных включают в себя SQL-серверы и любые
# другие источники, работающие с драйвером ODBC. UnixODBC содержит следующие
# компоненты:
#     - диспетчер драйверов
#     - библиотека установщика
#     - инструменты командной строки для установки драйвера и рабоыт с SQL
#     - драйверы и библиотеки для установки драйверов

# http://www.linuxfromscratch.org/blfs/view/stable/general/unixodbc.html

# Home page: http://www.iodbc.org/dataspace/iodbc/wiki/iODBC/
# Download:  ftp://ftp.unixodbc.org/pub/unixODBC/unixODBC-2.3.7.tar.gz

# Required: no
# Optional: mini-sql (http://www.hughes.com.au/products/msql/)
#           pth

ROOT="/root"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}${DOCS}"

# создавать драйверы, которые создавались по умолчанию в предыдущих версиях
#    --enable-drivers
# создавать библиотеки конфигурации драйверов, которые создавались по умолчанию
# в предыдущих версиях
#    --enable-drivers-conf
./configure               \
    --prefix=/usr         \
    --enable-drivers      \
    --enable-drivers-conf \
    --sysconfdir=/etc/unixODBC || exit 1

make || exit 1
# пакет не содержит набора тестов
make install
make install DESTDIR="${TMP_DIR}"

find doc -name "Makefile*" -delete
chmod 644 doc/{lst,ProgrammerManual/Tutorial}/*

install -v -m755 -d "${DOCS}"
find doc/ -type f -exec chmod 644 -vR {} \;
cp -vR doc/* "${DOCS}"
cp -vR doc/* "${TMP_DIR}${DOCS}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Independent Open DataBase Connectivity)
#
# The unixODBC package is an Open Source ODBC (Open DataBase Connectivity)
# sub-system and an ODBC SDK for Linux, Mac OSX, and UNIX. ODBC is an open
# specification for providing application developers with a predictable API
# with which to access data sources. Data sources include optional SQL Servers
# and any data source with an ODBC Driver. unixODBC contains the following
# components:
#    - a driver manager
#    - an installer library
#    - command line tools to help install a driver and work with SQL
#    - drivers and driver setup libraries
#
# Home page: http://www.iodbc.org/dataspace/iodbc/wiki/iODBC/
# Download:  ftp://ftp.unixodbc.org/pub/${ARCH_NAME}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
