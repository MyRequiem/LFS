#! /bin/bash

PRGNAME="libcddb"

### libcddb (An online CD database library)
# Библиотека, реализующая различные протоколы (CDDBP, HTTP, SMTP) для доступа к
# данным на сервере CDDB (http://freedb.org)

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# по умолчанию этот пакет обращается к сайту freedb.org, который уже закрыт и
# происходит переадресация на gnudb.org, поэтому изменим значение по умолчанию,
# чтобы вместо него использовалось gnudb.org, а так же исправим два устаревших
# файла тестовых данных:
sed -e '/DEFAULT_SERVER/s/freedb.org/gnudb.gnudb.org/' \
    -e '/DEFAULT_PORT/s/888/&0/'                       \
    -i include/cddb/cddb_ni.h                                          || exit 1
sed '/^Genre:/s/Trip-Hop/Electronic/' -i tests/testdata/920ef00b.txt   || exit 1
sed '/DISCID/i# Revision: 42'         -i tests/testcache/misc/12340000 || exit 1

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# make check -k
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (An online CD database library)
#
# Libcddb is a library that implements the different protocols (CDDBP, HTTP,
# SMTP) to access data on a CDDB server (http://freedb.org).
#
# Home page: http://${PRGNAME}.sourceforge.net/
# Download:  https://downloads.sourceforge.net/${PRGNAME}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
