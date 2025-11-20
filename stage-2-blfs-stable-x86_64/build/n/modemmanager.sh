#! /bin/bash

PRGNAME="modemmanager"
ARCH_NAME="ModemManager"

### ModemManager (mobile broadband modem API)
# Унифицированный API высокого уровня для связи с мобильными широкополосными
# модемами, независимо от протокола, используемого для связи с физическим
# устройством

# Required:    libgudev
# Recommended: elogind
#              glib
#              libmbim
#              libqmi
#              polkit
#              vala
# Optional:    gtk-doc

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup ..              \
    --prefix=/usr           \
    --buildtype=release     \
    -D bash_completion=true \
    -D qrtr=false           \
    -D systemdsystemunitdir=no || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (mobile broadband modem API)
#
# ModemManager provides a unified high level API for communicating with mobile
# broadband modems, regardless of the protocol used to communicate with the
# actual device
#
# Home page: https://gitlab.freedesktop.org/mobile-broadband/${ARCH_NAME}/
# Download:  https://gitlab.freedesktop.org/mobile-broadband/${ARCH_NAME}/-/archive/${VERSION}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
