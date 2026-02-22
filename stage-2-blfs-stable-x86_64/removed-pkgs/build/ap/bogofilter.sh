#! /bin/bash

PRGNAME="bogofilter"

### Bogofilter (mail filtering software)
# Спам-фильтр с открытым исходным кодом, который анализирует электронные письма
# и другие тексты, статистически проверяя их по спискам «хороших» (ham) и
# «плохих» (spam) слов, чтобы определить, является ли сообщение нежелательным,
# и классифицирует его как спам или не-спам (хам)

# Required:    no
# Recommended: gsl
#              libxml2
#              sqlite
# Optional:    lmdb
#              xmlto
#              berkeley-db      (https://anduin.linuxfromscratch.org/BLFS/bdb/db-5.3.28.tar.gz)
#              qdbm             (https://dbmx.net/qdbm/)
#              tokyocabinet     (https://dbmx.net/tokyocabinet/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure                        \
    --prefix=/usr                  \
    --sysconfdir="/etc/${PRGNAME}" \
    --with-database=sqlite3 || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (mail filtering software)
#
# The Bogofilter application is a mail filter that classifies mail as spam or
# ham (non-spam) by a statistical analysis of the message's header and content
# (body)
#
# Home page: https://${PRGNAME}.sourceforge.net
# Download:  https://downloads.sourceforge.net/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
