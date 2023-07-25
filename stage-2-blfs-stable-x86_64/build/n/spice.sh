#! /bin/bash

PRGNAME="spice"

### Spice (remote computing solution)
# Обеспечивает клиентский доступ к удаленным машинам и устройствам (клавиатура,
# мышь, аудио и т.д.)

# Required:    opus
#              python3-six
#              python-pyparsing (https://pypi.org/project/pyparsing/)
#              spice-protocol   (https://www.spice-space.org)
#              orc              (https://gstreamer.freedesktop.org/)
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

SMARTCARD="no"
[ -x /usr/lib/libcacard.so ] && SMARTCARD="yes"

./configure                           \
    --prefix=/usr                     \
    --enable-gstreamer=yes            \
    --enable-smartcard="${SMARTCARD}" \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

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
# Download:  https://www.${PRGNAME}-space.org/download/releases/${PRGNAME}-server/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
