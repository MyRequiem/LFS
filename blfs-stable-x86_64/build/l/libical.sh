#! /bin/bash

PRGNAME="libical"

### LibIcal (iCAL protocol implementation)
# Реализация IETF iCalendar, планирования и форматов данных (RFC 2445, 2446 и
# 2447). Анализирует компоненты iCal и предоставляет C/C++/Python/Java API для
# управления свойствами, параметрами, компонентами и подкомпонентами.

# http://www.linuxfromscratch.org/blfs/view/stable/general/libical.html

# Home page: https://github.com/libical/libical
# Download:  https://github.com/libical/libical/releases/download/v3.0.7/libical-3.0.7.tar.gz

# Required:    cmake
# Recommended: gobject-introspection
#              vala (см. опции конфигурации ниже)
# Optional:    berkeley-db
#              doxygen (для сборки API документации)
#              icu

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

INTROSPECTION="false"
VALA_API="false"
DOCS="false"
DOXYGEN=""
GTK_DOC=""

command -v g-ir-compiler &>/dev/null && INTROSPECTION="true"
command -v valac         &>/dev/null && VALA_API="true"
command -v doxygen       &>/dev/null && DOXYGEN="true"
command -v gtkdoc-check  &>/dev/null && GTK_DOC="true"

[[ -n "${DOXYGEN}" && -n "${GTK_DOC}" ]] && DOCS="true"

# применяем более высокий уровень оптимизации компилятора
#    -DCMAKE_BUILD_TYPE=Release
# создаем только общие (shared) библиотеки
#    -DSHARED_ONLY=yes
# предотвращаем сборку документации GTK
#    -DICAL_BUILD_DOCS=false
# генерируем привязки метаданных GObject
#    -DGOBJECT_INTROSPECTION=true
# сборка Vala API
#    -DICAL_GLIB_VAPI
# используем свой часовой пояс
#    -DUSE_BUILTIN_TZDATA=yes
cmake                                          \
    -DCMAKE_INSTALL_PREFIX=/usr                \
    -DCMAKE_BUILD_TYPE=Release                 \
    -DSHARED_ONLY=yes                          \
    -DICAL_BUILD_DOCS="${DOCS}"                \
    -DGOBJECT_INTROSPECTION="${INTROSPECTION}" \
    -DICAL_GLIB_VAPI="${VALA_API}"             \
    -DUSE_BUILTIN_TZDATA=yes                   \
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
