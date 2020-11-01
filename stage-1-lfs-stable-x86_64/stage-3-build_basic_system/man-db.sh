#! /bin/bash

PRGNAME="man-db"

### Man-DB (database-driven manual pager suite)
# Программы для поиска и просмотра man-страниц

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}config_file_processing.sh"             || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# отключает установку пользователя man для программы man
#    --disable-setuid
# общесистемные файлы кэша принадлежат пользователю bin
#    --enable-cache-owner=bin
# программы по умолчанию, которые можно установить позже: браузер w3m
#    --with-browser=/usr/bin/w3m
# 'vgrind' преобразует исходные тексты программы во входные данные Groff
#    --with-vgrind=/usr/bin/vgrind
# 'grap' полезен для набора графов в документах Groff
#    --with-grap=/usr/bin/grap
# не позволяем устанавливать ненужные системные каталоги и файлы
#    --with-systemdtmpfilesdir=
#    --with-systemdsystemunitdir=
./configure                       \
    --prefix=/usr                 \
    --sysconfdir=/etc             \
    --disable-setuid              \
    --enable-cache-owner=bin      \
    --with-browser=/usr/bin/w3m   \
    --with-vgrind=/usr/bin/vgrind \
    --with-grap=/usr/bin/grap     \
    --with-systemdtmpfilesdir=    \
    --with-systemdsystemunitdir=  \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || make -j1 || exit 1
make check
make install DESTDIR="${TMP_DIR}"

# бэкапим конфиг /etc/man_db.conf перед установкой пакета, если он существует
MAN_DB_CONF="/etc/man_db.conf"
if [ -f "${MAN_DB_CONF}" ]; then
    mv "${MAN_DB_CONF}" "${MAN_DB_CONF}.old"
fi

/bin/cp -vR "${TMP_DIR}"/* /

config_file_processing "${MAN_DB_CONF}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (database-driven manual pager suite)
#
# This package provides the man command and related utilities for examining
# on-line help files (manual pages). It has several enhancements over man,
# including an indexed database for searches with -k or apropos, the ability to
# easily view man pages in a browser, better i18n support, and a much more
# efficient implementation of the -K (full text search) option.
#
# Home page: https://www.nongnu.org/${PRGNAME}/
# Download:  http://download.savannah.gnu.org/releases/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
