#! /bin/bash

PRGNAME="wayland-protocols"

### Wayland-Protocols (extended Wayland protocols)
# Набор стандартов и технических описаний, которые определяют, как приложения и
# графическая оболочка должны взаимодействовать друг с другом (например, как
# разворачивать/сворачивать окна, работать с буфером обмена или вводом текста).
# Это своего рода «дополнительный свод правил», который расширяет базовые
# возможности Wayland для поддержки современных функций рабочего стола.

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

meson setup       \
    --prefix=/usr \
    --buildtype=release || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
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
