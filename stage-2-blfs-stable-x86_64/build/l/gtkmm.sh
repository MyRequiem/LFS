#! /bin/bash

PRGNAME="gtkmm"

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
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

DEMOS="false"
TESTS="false"
DOCS="false"
# command -v doxygen &>/dev/null && DOCS="true"

mkdir "${PRGNAME}3-build"
cd "${PRGNAME}3-build" || exit 1

meson                               \
    --prefix=/usr                   \
    --buildtype=release             \
    -Dbuild-x11-api=true            \
    -Dbuild-demos="${DEMOS}"        \
    -Dbuild-tests="${TESTS}"        \
    -Dbuild-documentation="${DOCS}" \
    .. || exit 1

ninja || exit 1

# тесты нужно запускать в графической среде, а так же изменить переменную TESTS
# выше на "true"
# ninja test

DESTDIR="${TMP_DIR}" ninja install

DOC_DIR="${TMP_DIR}/usr/share/doc/${PRGNAME}"
if [ -d "${DOC_DIR}-3.0" ]; then
    mv  "${DOC_DIR}-3.0" "${DOC_DIR}-${VERSION}"
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
# Home page: http://www.${PRGNAME}.org/
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
