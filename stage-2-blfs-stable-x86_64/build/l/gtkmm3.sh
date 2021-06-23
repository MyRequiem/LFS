#! /bin/bash

PRGNAME="gtkmm3"
ARCH_NAME="gtkmm"

### Gtkmm (C++ interface for GTK+3)
# C++ интерфейс для популярной библиотеки графического интерфейса GTK+3.
# Основные моменты это безопасные обратные вызовы и полный набор виджетов,
# которые легко расширяются с помощью наследования.

# Required:    atkmm
#              gtk+3
#              pangomm
# Recommended: no
# Optional:    doxygen (для сборки документации)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${ARCH_NAME}-3*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${ARCH_NAME}-${VERSION}"*.tar.?z* || exit 1
cd "${ARCH_NAME}-${VERSION}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

TESTS="false"
DOCS="false"
# command -v doxygen &>/dev/null && DOCS="true"

mkdir "${PRGNAME}-build"
cd "${PRGNAME}-build" || exit 1

meson                               \
    --prefix=/usr                   \
    -Dbuild-x11-api=true            \
    -Dbuild-tests="${TESTS}"        \
    -Dbuild-documentation="${DOCS}" \
    .. || exit 1

ninja || exit 1

# тесты нужно запускать в графической среде, а так же изменить переменную TESTS
# выше на "true"
# ninja test

DESTDIR="${TMP_DIR}" ninja install

if [[ "x${DOCS}" == "xtrue" ]]; then
    mv "${TMP_DIR}/usr/share/doc/${ARCH_NAME}-3.0" \
        "${TMP_DIR}/usr/share/doc/${PRGNAME}-${VERSION}"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (C++ interface for GTK+3)
#
# gtkmm is the official C++ interface for the popular GUI library GTK+ version
# 3. Highlights include typesafe callbacks, and a comprehensive set of widgets
# that are easily extensible via inheritance.
#
# Home page: http://www.${ARCH_NAME}.org/
# Download:  https://download.gnome.org/sources/${ARCH_NAME}/${MAJ_VERSION}/${ARCH_NAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
