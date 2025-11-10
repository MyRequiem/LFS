#! /bin/bash

PRGNAME="girara"

### girara (GTK+ based GUI for text-oriented applications)
# Библиотека, реализующая графический пользовательский интерфейс на основе GTK+
# для приложений, работающих с текстом (zathura, jumanji, etc). Ориентирована
# на простоту и минимализм.

# Required:    glib
#              gtk+3
# Recommended: no
# Optional:    json-glib
#              doxygen

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup ..       \
    --prefix=/usr    \
    -D docs=disabled \
    -D tests=disabled || exit 1

ninja || exit 1
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GTK+ based GUI for text-oriented applications)
#
# girara is a library that implements a user interface that focuses on
# simplicity and minimalism. girara was designed to replace and enhance the
# user interface that is used by zathura and jumanji and other features that
# those applications share.
#
# Home page: https://github.com/pwmt/${PRGNAME}
# Download:  https://github.com/pwmt/${PRGNAME}/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
