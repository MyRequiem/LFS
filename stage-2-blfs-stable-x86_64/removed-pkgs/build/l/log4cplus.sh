#! /bin/bash

PRGNAME="log4cplus"

### log4cplus (C++20 logging API)
# Простой в использовании API для логирования C++20, обеспечивающий
# поточно-ориентированный, гибкий и детальный контроль над управлением логами.
# Создан по образцу Java log4j API

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

V_E_R="${VERSION//./_}"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (C++20 logging API)
#
# log4cplus is an easy to use C++20 logging API providing thread-safe,
# flexible, and arbitrarily granular control over log management and
# configuration. It is modeled after the Java log4j API
#
# Home page: https://github.com/${PRGNAME}/${PRGNAME}/
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/releases/download/REL_${V_E_R}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
