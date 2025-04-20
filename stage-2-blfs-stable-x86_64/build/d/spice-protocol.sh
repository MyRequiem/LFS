#! /bin/bash

PRGNAME="spice-protocol"

### spice-protocol (SPICE protocol headers)
# Протокол Spice определяет набор сообщений для доступа, управления, и
# получение данных от удаленных вычислительных устройств (клавиатура, видео,
# мышь и т.д.) по сетям и отправки им вывода. Пакет содержит заголовочные
# файлы.

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

meson setup       \
    --prefix=/usr \
    .. || exit 1

ninja || exit 1
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
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
