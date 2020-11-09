#! /bin/bash

PRGNAME="libqmi"

### libqmi (Qualcomm MSM Interface (QMI) library and utils)
# Основанная на glib библиотека для общения с модемами и устройствами WWAN,
# которые передают данные по протоколу Qualcomm MSM Interface (QMI)

# http://www.linuxfromscratch.org/blfs/view/stable/general/libqmi.html

# Home page: https://www.freedesktop.org/wiki/Software/libqmi/
# Download:  https://www.freedesktop.org/software/libqmi/libqmi-1.24.4.tar.xz

# Required:    glib
# Recommended: libmbim
# Optional:    gtk-doc
#              help2man (https://ftp.gnu.org/gnu/help2man/)

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

LIBMBIM="no"
GTK_DOC="--disable-gtk-doc"

command -v mbimcli      &>/dev/null && LIBMBIM="yes"
command -v gtkdoc-check &>/dev/null && GTK_DOC="--enable-gtk-doc"

./configure                         \
    --prefix=/usr                   \
    --enable-mbim-qmux="${LIBMBIM}" \
    "${GTK_DOC}"                    \
    --disable-static || exit 1

make || exit 1
# make check
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Qualcomm MSM Interface (QMI) library and utils)
#
# libqmi is a glib-based library for talking to WWAN modems and devices which
# speak the Qualcomm MSM Interface (QMI) protocol
#
# Home page: https://www.freedesktop.org/wiki/Software/${PRGNAME}/
# Download:  https://www.freedesktop.org/software/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
