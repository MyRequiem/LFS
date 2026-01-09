#! /bin/bash

PRGNAME="libstatgrab"

### libstatgrab (access to statistics about the system on which it's run)
# Библиотека, обеспечивающая кроссплатформенный доступ к статистике о системе:
# использование ЦП, памяти, сетевой трафик, дисковое пространство, дисковый
# ввод-вывод и многое другое.

# Required:    no
# Recommended: no
# Optional:    log4cplus

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure          \
    --prefix=/usr    \
    --disable-static \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (access to statistics about the system on which it's run)
#
# This is a library that provides cross platform access to statistics about the
# system on which it's run. It's written in C and presents a selection of
# useful interfaces which can be used to access key system statistics. The
# current list of statistics includes CPU usage, memory utilisation, disk
# usage, process counts, network traffic, disk I/O, and more.
#
# Home page: https://github.com/${PRGNAME}/${PRGNAME}/
# Download:  https://www.mirrorservice.org/sites/ftp.i-scream.org/pub/i-scream/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
