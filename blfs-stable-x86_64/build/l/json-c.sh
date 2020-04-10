#! /bin/bash

PRGNAME="json-c"

### JSON-C
# Реализует объектную модель подсчета ссылок, которая позволяет легко
# конструировать объекты JSON в C, выводить их как строки в формате JSON и
# анализировать строки в JSON-формате обратно в C-представление объектов JSON

# http://www.linuxfromscratch.org/blfs/view/9.0/general/json-c.html

# Home page: https://github.com/json-c/json-c
# Download:  https://s3.amazonaws.com/json-c_releases/releases/json-c-0.13.1.tar.gz

# Required: no
# Optional: no

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# make check
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (JSON library in C)
#
# The JSON-C implements a reference counting object model that allows you to
# easily construct JSON objects in C, output them as JSON formatted strings and
# parse JSON formatted strings back into the C representation of JSON objects.
#
# Home page: https://github.com/json-c/${PRGNAME}
# Download:  https://s3.amazonaws.com/${PRGNAME}_releases/releases/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
