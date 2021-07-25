#! /bin/bash

PRGNAME="unixodbc"
ARCH_NAME="unixODBC"

### unixODBC (Open DataBase Connectivity for Unix platforms)
# Open DataBase Connectivity (ODBC) API для доступа к источникам данных
# (сервера SQL и любые другие с драйвером ODBC)

# Required:    no
# Recommended: no
# Optional:    pth
#              minisql (https://hughestech.com.au/products/msql/)

### Конфигурация
#    /etc/unixODBC/*

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1
source "${ROOT}/config_file_processing.sh"               || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

DOCS="false"

# создаем драйверы, которые были установлены по умолчанию в предыдущих версиях
# и библиотеки их конфигурации
#    --enable-drivers
#    --enable-drivers-conf
./configure               \
    --prefix=/usr         \
    --enable-drivers      \
    --enable-drivers-conf \
    --sysconfdir=/etc/unixODBC || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

if [[ "x${DOCS}" == "xtrue" ]]; then
    find doc/ -name "Makefile*" -delete
    find doc/ -type f -exec chmod 644 {} \;

    DOC_PATH="/usr/share/doc/${PRGNAME}-${VERSION}"
    install -v -m755 -d "${TMP_DIR}${DOC_PATH}"
    cp      -vR doc/*   "${TMP_DIR}${DOC_PATH}"
fi

ODBC_INI="/etc/unixODBC/odbc.ini"
ODBCINST_INI="/etc/unixODBC/odbcinst.ini"

if [ -f "${ODBC_INI}" ]; then
    mv "${ODBC_INI}" "${ODBC_INI}.old"
fi

if [ -f "${ODBCINST_INI}" ]; then
    mv "${ODBCINST_INI}" "${ODBCINST_INI}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${ODBC_INI}"
config_file_processing "${ODBCINST_INI}"

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
# Home page: http://www.${PRGNAME}.org/
# Download:  ftp://ftp.${PRGNAME}.org/pub/${ARCH_NAME}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
