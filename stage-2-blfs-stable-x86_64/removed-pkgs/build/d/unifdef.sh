#! /bin/bash

PRGNAME="unifdef"

### unifdef (Selectively processes C conditional compilation)
# Утилита для удаления условных выражений препроцессора из С кода

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим проблему сборки с gcc-15
sed -i 's/constexpr/unifdef_&/g' unifdef.c || exit 1

# исправим проблему при переустановке пакета
sed -i 's/ln -s/ln -sf/' Makefile || exit 1

make || exit 1
# make test
make prefix=/usr install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share/doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Selectively processes C conditional compilation)
#
# The unifdef package contains a utility that is useful for removing
# preprocessor conditionals from code
#
# Home page: https://dotat.at/prog/${PRGNAME}/
# Download:  https://dotat.at/prog/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
