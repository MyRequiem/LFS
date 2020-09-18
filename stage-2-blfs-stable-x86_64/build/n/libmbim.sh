#! /bin/bash

PRGNAME="libmbim"

### libmbim (Mobile Broadband Interface Model library and utils)
# Mobile Broadband Interface Model (MBIM) - это стандарт взаимодействия с
# модемами мобильного широкополосного доступа, разработанным на форуме
# USB-разработчиков. Пакет содержит основанную на GLib библиотеку для общения с
# модемами WWAN и другими устройствами, которые используют протокол MBIM

# http://www.linuxfromscratch.org/blfs/view/stable/general/libmbim.html

# Home page: https://www.freedesktop.org/wiki/Software/libmbim/
# Download:  https://www.freedesktop.org/software/libmbim/libmbim-1.22.0.tar.xz

# Required: libgudev
# Optional: gtk-doc
#           help2man (https://ftp.gnu.org/gnu/help2man/)

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

GTK_DOC="--disable-gtk-doc"
command -v gtkdoc-check &>/dev/null && GTK_DOC="--enable-gtk-doc"

./configure         \
    --prefix=/usr   \
    --with-udev=yes \
    "${GTK_DOC}"    \
    --disable-static || exit 1

make || exit 1
# make check
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (MBIM library and utils)
#
# The Mobile Broadband Interface Model (MBIM) is a new standard to communicate
# with mobile broadband modem devices developed by the USB Implementors Forum.
# Package contains a GLib-based library for talking to WWAN modems and devices
# which speak the MBIM protocol.
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
