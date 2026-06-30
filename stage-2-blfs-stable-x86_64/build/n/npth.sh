#! /bin/bash

PRGNAME="npth"

### NPth (New GNU Portable Threads Library)
# Библиотека для управления параллельными задачами в программах (потоками в
# пользовательском пространстве), ориентированная на использование в проектах
# GnuPG

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure \
    --prefix=/usr || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (New GNU Portable Threads Library)
#
# nPth is a non-preemptive threads implementation using an API very similar to
# the one known from GNU Pth. It has been designed as a replacement of GNU Pth
# for non-ancient operating systems. In contrast to GNU Pth is is based on the
# system's standard threads implementation. Thus nPth allows the use of
# libraries which are not compatible to GNU Pth
#
# Home page: https://gnupg.org/software/${PRGNAME}/index.html
# Download:  https://www.gnupg.org/ftp/gcrypt/${PRGNAME}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
