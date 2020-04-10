#! /bin/bash

PRGNAME="libical"

### LibIcal
# Реализация IETF iCalendar, планирования и форматов данных (RFC 2445, 2446 и
# 2447). Анализирует компоненты iCal и предоставляет C/C++/Python/Java API для
# управления свойствами, параметрами, компонентами и подкомпонентами.

# http://www.linuxfromscratch.org/blfs/view/9.0/general/libical.html

# Home page: https://github.com/libical/libical
# Download:  https://github.com/libical/libical/releases/download/v3.0.5/libical-3.0.5.tar.gz

# Required: cmake
# Optional: berkeley-db
#           doxygen (for the api documentation)
#           gobject-introspection
#           icu

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

# применяем более высокий уровень оптимизации компилятора
#    -DCMAKE_BUILD_TYPE=Release
# создаваем только общие (shared) библиотеки
#    -DSHARED_ONLY=yes
# предотвращаем сборку документации GTK
#    -DICAL_BUILD_DOCS=false
cmake                           \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release  \
    -DSHARED_ONLY=yes           \
    -DICAL_BUILD_DOCS=false     \
    .. || exit 1

make || exit 1
# make test
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (iCAL protocol implementation)
#
# libical is an Open Source (MPL/LGPL) implementation of the IETF's iCalendar
# Calendaring, scheduling protocols and data formats (RFC 2445, 2446, and
# 2447). It parses iCal components and provides C/C++/Python/Java APIs for
# manipulating the component properties, parameters, and subcomponents.
#
# Home page: https://github.com/${PRGNAME}/${PRGNAME}
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
