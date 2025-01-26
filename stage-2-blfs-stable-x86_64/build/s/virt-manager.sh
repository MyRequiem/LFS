#! /bin/bash

PRGNAME="virt-manager"

### virt-manager (a gtk interface for libvirt)
# GTK интерфейс для libvirt

# Required:    libvirt
#              libvirt-glib
#              python3-libvirt
#              python3-installer
#              python3-pyproject-hooks
#              python3-pygobject3
#              python3-ipaddr
#              python3-requests
#              python3-build
#              gtk+3
#              spice-gtk
#              gtk-vnc
#              tunctl
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/usr/share/"{icons/hicolor,glib-2.0/schemas}

mkdir build
cd build || exit 1

meson setup ..           \
    --prefix=/usr        \
    --buildtype=release  \
    --localstatedir=/var \
    --sysconfdir=/etc    \
    -D tests=disabled    \
    -D default-hvs=qemu,lxc || exit 1

ninja || exit 1
DESTDIR=${TMP_DIR} ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# обновим кэш иконок приложений и схемы для Glib
gtk-update-icon-cache -q -t /usr/share/icons/hicolor
glib-compile-schemas /usr/share/glib-2.0/schemas

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a gtk interface for libvirt)
#
# The virt-manager application is a desktop user interface for managing virtual
# machines through libvirt. It primarily targets KVM VMs, but also manages Xen,
# qemu/kvm, virtualbox, LXC (linux containers) and perhaps others. It presents
# a summary view of running domains, their live performance & resource
# utilization statistics. Wizards enable the creation of new domains, and
# configuration & adjustment of a domain’s resource allocation & virtual
# hardware. An embedded VNC and SPICE client viewer presents a full graphical
# console to the guest domain.
#
# Home page: https://${PRGNAME}.org/
# Download:  https://releases.pagure.org/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
