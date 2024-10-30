#! /bin/bash

PRGNAME="wayland-protocols"

### Wayland-Protocols (extended Wayland protocols)
# Дополнительные протоколы Wayland, которые добавляют функциональность
# недоступную в основном протоколе Wayland. Такие протоколы либо добавляют
# совершенно новый функционал, либо расширяют функционал других протоколов.

# Required:    wayland
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson             \
    --prefix=/usr \
    -Dtests=false \
    --buildtype=release || exit 1

ninja || exit 1

# для тестов устанавливаем параметр конфигурации -Dtests=true
# ninja test

DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (extended Wayland protocols)
#
# wayland-protocols contains Wayland protocols that add functionality not
# available in the Wayland core protocol. Such protocols either add completely
# new functionality, or extend the functionality of some other protocol either
# in Wayland core or in wayland-protocols.
#
# Home page: https://wayland.freedesktop.org/
# Download:  https://gitlab.freedesktop.org/wayland/${PRGNAME}/-/releases/${VERSION}/downloads/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
