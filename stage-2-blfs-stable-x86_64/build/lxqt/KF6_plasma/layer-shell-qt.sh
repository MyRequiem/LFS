#! /bin/bash

PRGNAME="layer-shell-qt"

### layer-shell-qt (easily use clients based on a "wlr-layer-shell" protocol)
# Компонент позволяющий приложениям легко использовать клиентов на основе
# протокола wlr-layer-shell

# Required:    extra-cmake-modules
#              qt6
# Recommended: no
# Optional:    no

###
# NOTE:
#    Нет необходимости в этом пакете, если установлен пакет plasma (KDE)
###

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

cmake                            \
    -D CMAKE_INSTALL_PREFIX=/usr \
    -D CMAKE_BUILD_TYPE=Release  \
    -W no-dev                    \
    .. || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (easily use clients based on a "wlr-layer-shell" protocol)
#
# This component is meant for applications to be able to easily use clients
# based on a "wlr-layer-shell" protocol. Clients can use this interface to
# assign the surface_layer role to wl_surfaces. Such surfaces are assigned to a
# "layer" of the output and rendered with a defined z-depth respective to each
# other
#
# Home page: https://kde.org/
# Download:  https://download.kde.org/stable/plasma/${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
