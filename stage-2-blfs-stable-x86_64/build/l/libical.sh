#! /bin/bash

PRGNAME="libical"

### libical (iCAL protocol implementation)
# Реализация протокола iCalendar, который анализирует iCal компоненты и
# предоставляет C/C++/Python/Java API для управления свойствами и параметрами
# компонентов.

# Required:    cmake
# Recommended: gobject-introspection
#              vala
# Optional:    berkeley-db
#              doxygen           (для сборки API документации)
#              gtk-doc           (для сборки API документации)
#              icu
#              python-pygobject3 (для некоторых тестов)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

DOCS="false"
VALA_API="false"
INTROSPECTION="false"

# command -v doxygen &>/dev/null && command -v gtkdoc-check &>/dev/null && \
#     DOCS="true"

command -v vala          &>/dev/null && VALA_API="true"
command -v g-ir-compiler &>/dev/null && INTROSPECTION="true"

mkdir build
cd build || exit 1

cmake                                        \
    -DCMAKE_INSTALL_PREFIX=/usr              \
    -DCMAKE_BUILD_TYPE=Release               \
    -DSHARED_ONLY=yes                        \
    -DICAL_BUILD_DOCS=${DOCS}                \
    -DICAL_GLIB_VAPI=${VALA_API}             \
    -DGOBJECT_INTROSPECTION=${INTROSPECTION} \
    .. || exit 1

# этот пакет может иногда давать сбой при сборке в несколько потоков, поэтому
# явно указываем -j1
make -j1 || exit 1

[[ "x${DOCS}" == "xtrue" ]] && make -j1 docs

# make test

make install DESTDIR="${TMP_DIR}"

if [[ "x${DOCS}" == "xtrue" ]]; then
    DOC_PATH="${TMP_DIR}/usr/share/doc/${PRGNAME}-${VERSION}/html"
    install -vdm755 "${DOC_PATH}"
    cp -vr apidocs/html/* "${DOC_PATH}"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (iCAL protocol implementation)
#
# libical is an Open Source implementation of the IETF's iCalendar Calendaring
# and Scheduling protocols and data formats. It parses iCal components and
# provides C/C++/Python/Java APIs for manipulating the component properties,
# parameters, and subcomponents.
#
# Home page: https://github.com/${PRGNAME}/${PRGNAME}
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
