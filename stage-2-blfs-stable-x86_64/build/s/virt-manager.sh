#! /bin/bash

PRGNAME="virt-manager"

### virt-manager (A GTK interface for libvirt)
# Графическое приложение (GUI) для удобного управления виртуальными машинами,
# сетями и хранилищами. Позволяет в один клик создавать, настраивать и
# запускать гостевые операционные системы в средах виртуализации KVM и QEMU
# через libvirt.

# Required:    spice-gtk
#              libosinfo
#              gtk-vnc
#              libvirt-glib
#              tunctl
#              python3-lxml
#              python3-libvirt
#              python3-pygobject3
#              python3-ipaddr
#              python3-requests
#              python3-build
#              python3-urlgrabber
#              gtksourceview4       (runtime)
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/usr/share/"{icons/hicolor,glib-2.0/schemas}

# ==============================================================================
# Описание патча libxml2-compat.patch (Бэкпорт из апстрима, Pull Request #927)
#    xmlapi: rewrite the code to use lxml instead of libxml2
# ==============================================================================
# Патч устраняет несовместимость с libxml2 >= 2.15.x и готовит пакет к
# libxml2-2.16
#
#    - вырезает использование устаревших Python-биндингов libxml2, что
#       избавляет от AttributeError на методах keepBlanksDefault, parseDoc, ...
#    - переводит внутренний движок парсинга (virtinst/xmlapi.py) на библиотеку
#       lxml
#    - сохраняет многопоточную безопасность при работе с libvirt-python API
#
# Требования (Runtime):
#    - необходим установленный пакет python-lxml в системе
# Преимущества:
#    - позволяет собирать сам системный libxml2 с флагом -D python=disabled
# ==============================================================================
patch --verbose -Np1 -i "${SOURCES}/${PRGNAME}-libxml2-compat.patch" || exit 1

mkdir build
cd build || exit 1

meson setup ..              \
    --prefix=/usr           \
    --buildtype=release     \
    --localstatedir=/var    \
    --sysconfdir=/etc       \
    -D tests=disabled       \
    -D default-hvs=qemu,lxc \
    -D compile-schemas=false || exit 1

ninja || exit 1
DESTDIR=${TMP_DIR} ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# обновим кэш иконок приложений и схемы для Glib
gtk-update-icon-cache -q -t /usr/share/icons/hicolor
glib-compile-schemas /usr/share/glib-2.0/schemas

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (A GTK interface for libvirt)
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
