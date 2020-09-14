#! /bin/bash

PRGNAME="modem-manager"
ARCH_NAME="ModemManager"

### ModemManager (mobile broadband modem API)
# Единый API высокого уровня для связи с мобильным широкополосными модемами,
# независимо от протокола, используемого для связи с физическим устройством.

# http://www.linuxfromscratch.org/blfs/view/stable/general/ModemManager.html

# Home page: https://www.freedesktop.org/wiki/Software/ModemManager/
# Download:  https://www.freedesktop.org/software/ModemManager/ModemManager-1.12.6.tar.xz

# Required:    libgudev
# Recommended: elogind
#              gobject-introspection
#              libmbim
#              libqmi
#              polkit
#              vala
# Optional:    gtk-doc

ROOT="/root"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

GTK_DOC="--disable-gtk-doc"
LIBMBIM="--without-mbim"
LIBQMI="--without-qmi"
VALA="no"
POLKIT="no"
INTROSPECTION="no"

command -v gtkdoc-check  &>/dev/null && GTK_DOC="--enable-gtk-doc"
command -v mbimcli       &>/dev/null && LIBMBIM="--with-mbim"
command -v qmicli        &>/dev/null && LIBQMI="--with-qmi"
command -v valac         &>/dev/null && VALA="yes"
command -v pkcheck       &>/dev/null && POLKIT="strict"
command -v g-ir-compiler &>/dev/null && INTROSPECTION="yes"

# не использовать журнал systemd
#    --with-systemd-journal=no
# не включать поддержку systemd для suspend/resume
#    --with-systemd-suspend-resume=no
./configure                                   \
    --prefix=/usr                             \
    --sysconfdir=/etc                         \
    --localstatedir=/var                      \
    --disable-static                          \
    --enable-more-warnings=no                 \
    --with-systemd-journal=no                 \
    "${GTK_DOC}"                              \
    "${LIBMBIM}"                              \
    "${LIBQMI}"                               \
    --enable-vala="${VALA}"                   \
    --with-polkit="${POLKIT}"                 \
    --enable-introspection="${INTROSPECTION}" \
    --with-systemd-suspend-resume=no || exit 1

make || exit 1
# make check
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (mobile broadband modem API)
#
# ModemManager provides a unified high level API for communicating with mobile
# broadband modems, regardless of the protocol used to communicate with the
# actual device.
#
# Home page: https://www.freedesktop.org/wiki/Software/${ARCH_NAME}/
# Download:  https://www.freedesktop.org/software/${ARCH_NAME}/${ARCH_NAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
