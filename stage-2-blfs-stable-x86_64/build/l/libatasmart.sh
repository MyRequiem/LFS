#! /bin/bash

PRGNAME="libatasmart"

### libatasmart (ATA S.M.A.R.T. library)
# Компактная и чистая реализация ATA S.M.A.R.T. (Self-Monitoring, Analysis and
# Reporting Technology) для жестких дисков ATA

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# пакет не содержит набора тестов
make docdir="/usr/share/doc/${PRGNAME}-${VERSION}" install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (ATA S.M.A.R.T. library)
#
# libatasmart is a lean, small and clean implementation of an ATA S.M.A.R.T.
# (Self-Monitoring, Analysis and Reporting Technology) reading and parsing
# library. S.M.A.R.T. is a system used by hard drives to monitor factors that
# may impact drive reliability in the hope of predicting a drive failure before
# it occurs.
#
# Home page: http://0pointer.de/blog/projects/being-smart.html
# Download:  http://0pointer.de/public/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
