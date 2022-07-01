#! /bin/bash

PRGNAME="jq"

### jq (command-line JSON processor)
# Легкий и гибкий процессор JSON для командной строки. jq похож на sed, только
# для данных JSON. Можно использовать для нарезки, фильтрации, сопоставления и
# преобразования структурированных данных так же легко, как это позволяют sed,
# awk, grep и т.д.

# Required:    oniguruma
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure              \
    --prefix=/usr        \
    --sysconfdir=/etc    \
    --localstatedir=/var \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

mv "${TMP_DIR}/usr/share/doc/"{"${PRGNAME}","${PRGNAME}-${VERSION}"}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (command-line JSON processor)
#
# jq is a lightweight and flexible command-line JSON processor. jq is like sed
# for JSON data - you can use it to slice and filter and map and transform
# structured data with the same ease that sed, awk, grep and friends let you
# play with text.
#
# Home page: https://stedolan.github.io/${PRGNAME}/
# Download:  https://github.com/stedolan/${PRGNAME}/releases/download/${PRGNAME}-${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
