#! /bin/bash

PRGNAME="libgusb"

### libgusb (Glib Wrapper for libusb)
# GObject обертка для libusb

# Required:    json-glib
#              libusb
# Recommended: glib
#              hwdata
#              vala
# Optional:    python3-gi-docgen
#              umockdev

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup ..          \
    --prefix=/usr       \
    --buildtype=release \
    -D docs=false || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Glib Wrapper for libusb)
#
# The libgusb package contains the GObject wrappers for libusb-1.0 that makes
# it easy to do asynchronous control, bulk and interrupt transfers with proper
# cancellation and integration into a mainloop
#
# Home page: https://github.com/hughsie/${PRGNAME}/
# Download:  https://github.com/hughsie/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
