#! /bin/bash

PRGNAME="gtk-engines"
MURRINE="murrine"

### GTK Engines (themes and engines for GTK2)
# Дополнительные темы (Clearlooks, Crux, Industrial, Mist, Redmond и ThinIce) и
# движки для GTK2 + murrine (Gtk2 Cairo Engine)

# Required:    gtk+2
#              lua
#              cairo
# Recommended: no
# Optional:    which (для тестов)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --enable-lua  \
    --with-system-lua || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

###
# собираем движок murrine
###
SOURCES="${ROOT}/src"
MURRINE_VERSION="$(find "${SOURCES}" -type f \
    -name "${MURRINE}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

cd "${BUILD_DIR}" || exit 1
tar xvf "${SOURCES}/${MURRINE}-${MURRINE_VERSION}"*.tar.?z* || exit 1
cd "${MURRINE}-${MURRINE_VERSION}" || exit 1

./configure            \
    --prefix=/usr      \
    --sysconfdir=/etc  \
    --enable-animation \
    --localstatedir=/var || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
MURRINE_MAJ_VERSION="$(echo "${MURRINE_VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (themes and engines for GTK2)
#
# The GTK Engines package contains themes and engines for GTK2
#
# Home page: https://download.gnome.org/sources/${PRGNAME}/
#            https://launchpad.net/murrine/
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.bz2
#            http://ftp.acc.umu.se/pub/GNOME/sources/${MURRINE}/${MURRINE_MAJ_VERSION}/${MURRINE}-${MURRINE_VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
