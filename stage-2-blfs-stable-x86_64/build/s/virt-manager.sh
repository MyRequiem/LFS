#! /bin/bash

PRGNAME="virt-manager"

### virt-manager (a gtk interface for libvirt)
# GTK интерфейс для libvirt

# Required:    spice-protocol
#              spice
#              libyajl
#              libvirt
#              osinfo-db-tools
#              osinfo-db
#              libosinfo
#              libvirt-glib
#              python3-libvirt
#              gtk-vnc
#              spice-gtk
#              tunctl
#              python-ipaddr
#              python3-requests
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/usr/share/"{icons/hicolor,glib-2.0/schemas}

patch --verbose -Np1 -i \
    "${SOURCES}/add-slackware-to-os-choices-${VERSION}.patch" || exit 1

python3 setup.py build || exit 1
python3 setup.py install --optimize=1 --root="${TMP_DIR}"

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
# Download:  https://${PRGNAME}.org/download/sources/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
