#! /bin/bash

PRGNAME="libiodbc"

### libiodbc (Independent Open DataBase Connectivity)
# API для ODBC-совместимых баз данных

# Required:    no
# Recommended: gtk+2 (для сборки GUI утилиты администрирования)
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
ETC_IODBC="/etc/iodbc"
mkdir -pv "${TMP_DIR}${ETC_IODBC}"

# каталог установки файлов конфигурации
#    --with-iodbc-inidir=/etc/iodbc
# заголовки устанавливаем в отдельный каталог, чтобы избежать конфликта с
# заголовками, установленными с пакетом 'unixodbc'
#    --includedir=/usr/include/iodbc
# не собираем libodbc.so, чтобы избежать конфликта с пакетом 'unixodbc'
#    --disable-libodbc
./configure                         \
    --prefix=/usr                   \
    --sysconfdir=/etc               \
    --with-iodbc-inidir=/etc/iodbc  \
    --includedir=/usr/include/iodbc \
    --disable-libodbc               \
    --disable-static || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

install -v -m644 etc/odbc.ini.sample     "${TMP_DIR}${ETC_IODBC}"
install -v -m644 etc/odbcinst.ini.sample "${TMP_DIR}${ETC_IODBC}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Independent Open DataBase Connectivity)
#
# iODBC is the acronym for Independent Open DataBase Connectivity, an Open
# Source platform independent implementation of both the ODBC and X/Open
# specifications. It allows for developing solutions that are language,
# platform and database independent.
#
# Home page: https://www.iodbc.org
# Download:  https://downloads.sourceforge.net/iodbc/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
