#! /bin/bash

PRGNAME="libiodbc"

### libiodbc (Independent Open DataBase Connectivity)
# API для ODBC-совместимых баз данных

# http://www.linuxfromscratch.org/blfs/view/stable/general/libiodbc.html

# Home page: http://www.iodbc.org/dataspace/iodbc/wiki/iODBC/
# Download:  https://downloads.sourceforge.net/iodbc/libiodbc-3.52.12.tar.gz

# Required:    no
# Recommended: gtk+2 (для сборки GUI-инструмента администрирования)
# Optional:    no

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

GTK_TEST="--disable-gtktest"
command -v gtk-demo &>/dev/null && GTK_TEST="--enable-gtktest"

# путь к файлам конфигурации
#    --with-iodbc-inidir=/etc/iodbc
# устанавливаем заголовочные файлы в собственный каталог, чтобы избежать
# конфликта с заголовками, установленными пакетом unixODBC
#    --includedir=/usr/include/iodbc
# не создаем символическую ссылку libodbc.so, чтобы избежать конфликта с
# пакетом unixODBC
#    --disable-libodbc
./configure                         \
    --prefix=/usr                   \
    --with-iodbc-inidir=/etc/iodbc  \
    --includedir=/usr/include/iodbc \
    --disable-libodbc               \
    "${GTK_TEST}"                   \
    --disable-static || exit 1

make || exit 1
# пакет не содержит набора тестов
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Independent Open DataBase Connectivity)
#
# iODBC is the acronym for Independent Open DataBase Connectivity, an Open
# Source platform independent implementation of both the ODBC and X/Open
# specifications. It allows for developing solutions that are language,
# platform and database independent.
#
# Home page: http://www.iodbc.org/dataspace/iodbc/wiki/iODBC/
# Download:  https://downloads.sourceforge.net/iodbc/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
