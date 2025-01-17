#! /bin/bash

PRGNAME="spice-gtk"

### spice-gtk (spice gtk client/libraries)
# Gtk-клиент и библиотеки для удаленных рабочих столов Spice

# Required:    vala
#              spice             (https://www.spice-space.org/)
# Recommended: polkit
# Optional:    libcacard        (https://www.spice-space.org/)
#              usbredir         (https://www.spice-space.org)
#              phodav           (https://wiki.gnome.org/phodav)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

GTK_DOC="disabled"
SMARTCARD="disabled"
INTROSPECTION="disabled"
POLKIT="disabled"
USBREDIR="disabled"

[ -x /usr/lib/libcacard.so ]         && SMARTCARD="enabled"
command -v g-ir-compiler &>/dev/null && INTROSPECTION="enabled"
command -v pkaction      &>/dev/null && POLKIT="enabled"
command -v usbredirect   &>/dev/null && USBREDIR="enabled"

mkdir build
cd build || exit 1

meson                                  \
    --prefix=/usr                      \
    -Dopus=enabled                     \
    -Dvapi=enabled                     \
    -Dgtk_doc="${GTK_DOC}"             \
    -Dsmartcard="${SMARTCARD}"         \
    -Dpolkit="${POLKIT}"               \
    -Dusbredir="${USBREDIR}"           \
    -Dintrospection="${INTROSPECTION}" \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (spice gtk client/libraries)
#
# A Gtk client and libraries for spice remote desktop servers
#
# Home page: https://www.spice-space.org
# Download:  https://www.spice-space.org/download/gtk/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
