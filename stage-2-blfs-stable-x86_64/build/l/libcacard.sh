#! /bin/bash

PRGNAME="libcacard"

### libcacard (Virtual Smart Card Emulator library)
# Пакет предназначен для эмуляции реальных смарт-карт в виртуальном картридере,
# работающем на гостевой виртуальной машине.

# Required:    glib
#              pcsc-lite
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup               \
    --prefix=/usr         \
    -D pcsc=enabled       \
    -D disable_tests=true \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Virtual Smart Card Emulator library)
#
# This emulator is designed to provide emulation of actual smart cards to a
# virtual card reader running in a guest virtual machine. The emulates smart
# cards can be representations of real smart cards, or the cards could be pure
# software constructs.
#
# Home page: https://www.spice-space.org/
# Download:  https://www.spice-space.org/download/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
