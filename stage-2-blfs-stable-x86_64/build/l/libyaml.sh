#! /bin/bash

PRGNAME="libyaml"
ARCH_NAME="yaml"

### libyaml (YAML parser, written in C)
# Библиотека YAML стандарта (удобная сериализация данных) для всех языков
# программирования.

# Required:    no
# Recommended: no
# Optional:    doxygen

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure        \
    --prefix=/usr  \
    --disable-static || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (YAML parser, written in C)
#
# YAML Ain't Markup Language. It is a human friendly data serialization
# standard for all programming languages.
#
# Home page: https://pyyaml.org/wiki/LibYAML
# Download:  https://github.com/yaml/${PRGNAME}/releases/download/${VERSION}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
