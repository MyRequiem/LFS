#! /bin/bash

PRGNAME="gvfs"

### Gvfs (glib virtual filesystems)
# Виртуальная файловая система пользовательского пространства, предназначенная
# для работы с библиотекой GLib

# Required:    dbus
#              glib
#              gcr4
#              libusb
#              libsecret
# Recommended: gtk+3
#              libcdio
#              libgudev
#              libsoup3
#              elogind
#              udisks
# Optional:    apache
#              avahi
#              bluez
#              fuse3
#              gnome-online-accounts
#              gtk-doc
#              libarchive
#              libgcrypt
#              libxml2
#              libxslt
#              openssh
#              samba
#              gnome-desktop-testing        (для тестов) https://download.gnome.org/sources/gnome-desktop-testing/
#              libbluray                    (https://www.videolan.org/developers/libbluray.html)
#              libgdata                     (https://gitlab.gnome.org/GNOME/libgdata)
#              libgphoto2                   (http://www.gphoto.org/)
#              libimobiledevice             (https://libimobiledevice.org/)
#              libmsgraph                   (https://gitlab.gnome.org/GNOME/msgraph)
#              libmtp                       (https://libmtp.sourceforge.net/)
#              libnfs                       (https://github.com/sahlberg/libnfs/)
#              twisted                      (https://twisted.org/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup                  \
    --prefix=/usr            \
    --buildtype=release      \
    -D onedrive=false        \
    -D fuse=true             \
    -D gphoto2=false         \
    -D afc=false             \
    -D bluray=false          \
    -D nfs=false             \
    -D mtp=false             \
    -D smb=false             \
    -D tmpfilesdir=no        \
    -D dnssd=true            \
    -D goa=false             \
    -D google=false          \
    -D systemduserunitdir=no \
    .. || exit 1

ninja || exit 1
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# обновим /usr/share/glib-2.0/schemas/gschemas.compiled
glib-compile-schemas /usr/share/glib-2.0/schemas

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (glib virtual filesystems)
#
# The Gvfs package is a userspace virtual filesystem designed to work with the
# I/O abstractions of GLib's GIO library
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
