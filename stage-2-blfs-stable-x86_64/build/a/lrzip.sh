#! /bin/bash

PRGNAME="lrzip"

### lrzip (Long Range ZIP)
# Специальный инструмент для упаковки очень больших файлов (сотни мегабайт и
# гигабайты). Он анализирует весь объём данных целиком, достигая феноменальной
# степени сжатия там, где другие пасуют.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/etc"

./configure           \
    --prefix=/usr     \
    --disable-static  \
    --sysconfdir=/etc \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

LRZIP_CONF="/etc/lrzip.conf"
install -m644 -o root -g root -D doc/lrzip.conf.example \
    "${TMP_DIR}${LRZIP_CONF}"

if [ -f "${LRZIP_CONF}" ]; then
    mv "${LRZIP_CONF}" "${LRZIP_CONF}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${LRZIP_CONF}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Long Range ZIP)
#
# LRZIP is a file compression program designed to do particularly well on very
# large files containing long distance redundancy. The larger the file and the
# more memory you have, the better the compression advantage this will provide.
# A variety of compression options allow optimizing for size or speed.
#
# Home page: http://ck.kolivas.org/apps/${PRGNAME}/
# Download:  http://ck.kolivas.org/apps/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
