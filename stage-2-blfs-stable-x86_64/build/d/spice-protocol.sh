#! /bin/bash

PRGNAME="spice-protocol"

### spice-protocol (SPICE protocol headers)
# Набор правил и технических протоколов (заголовочных файлов) для организации
# удаленного доступа к рабочему столу. Он координирует передачу видео, звука и
# команд мыши между сервером и клиентом.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup .. \
    --prefix=/usr || exit 1

ninja || exit 1
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (SPICE protocol headers)
#
# Spice protocol defines a set of protocol messages for accessing, controlling,
# and receiving inputs from remote computing devices (e.g., keyboard, video,
# mouse) across networks, and sending output to them. These are the protocol
# header files.
#
# Home page: https://www.spice-space.org
# Download:  https://www.spice-space.org/download/releases/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
