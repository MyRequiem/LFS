#! /bin/bash

PRGNAME="fdk-aac"

### fdk-aac (Fraunhofer FDK AAC code from Android.)
# Библиотека Fraunhofer FDK AAC (код из Android), которая якобы является
# высококачественной реализацией Advanced Audio Coding (AAC)

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
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Fraunhofer FDK AAC code from Android.)
#
# fdk-aac package provides the Fraunhofer FDK AAC library (code from Android),
# which is purported to be a high quality Advanced Audio Coding implementation
#
# Home page: https://github.com/mstorsjo/${PRGNAME}
# Download:  https://downloads.sourceforge.net/opencore-amr/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
