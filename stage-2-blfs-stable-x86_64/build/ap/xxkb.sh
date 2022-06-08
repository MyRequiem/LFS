#! /bin/bash

PRGNAME="xxkb"

### xxkb (simple X keyboard layout switcher)
# Переключатель и индикатор раскладки клавиатуры

# Required:    imake
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${PRGNAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 2 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}-${VERSION}-src"*.tar.?z* || exit 1
cd "${PRGNAME}-${VERSION}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
MAN_DIR="/usr/share/man/man1"
mkdir -pv "${TMP_DIR}${MAN_DIR}"

xmkmf                          || exit 1
make EXTRA_DEFINES=-USHAPE_EXT || exit 1
make install DESTDIR="${TMP_DIR}"

cp "${PRGNAME}.man" "${TMP_DIR}${MAN_DIR}/${PRGNAME}.1"
rm -rf "${TMP_DIR}/usr/lib"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (simple X keyboard layout switcher)
#
# The xxkb program is a keyboard layout switcher and indicator. Unlike the
# programs that reload keyboard maps and use their own hot-keys, xxkb is a
# simple GUI for XKB (X KeyBoard extension) and just sends commands to and
# accepts events from XKB. That means that it will work with the existing setup
# of your X Server without any modifications.
#
# Home page: https://www.sourceforge.net/projects/${PRGNAME}/
# Download:  https://downloads.sourceforge.net/project/${PRGNAME}/${PRGNAME}-${VERSION}-src.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
