#! /bin/bash

PRGNAME="spice"

### Spice (remote computing solution)
# Обеспечивает клиентский доступ к удаленным машинам и устройствам (клавиатура,
# мышь, аудио и т.д.)

# Required:    glib
#              spice-protocol       (https://www.spice-space.org)
#              pixman
#              libjpeg-turbo
#              python3-six
#              python3-pyparsing
# Recommended: no
# Optional:    cyrus-sasl
#              libcacard
#              opus
#              gstreamer
#              orc                  (https://gstreamer.freedesktop.org/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup             \
    --prefix=/usr       \
    --buildtype=release \
    -D tests=false      \
    .. || exit 1

ninja || exit 1
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (remote computing solution)
#
# Spice is an open remote computing solution, providing client access to remote
# machine display and devices (e.g., keyboard, mouse, audio). Spice achieves a
# user experience similar to an interaction with a local machine, while trying
# to offload most of the intensive CPU and GPU tasks to the client. Spice is
# suitable for both LAN and WAN usage, without compromising on the user
# experience.
#
# Home page: https://www.${PRGNAME}-space.org
# Download:  https://www.${PRGNAME}-space.org/download/releases/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
