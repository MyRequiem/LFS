#! /bin/bash

PRGNAME="transmission"

### Transmission (BitTorrent client)
# Легкий BitTorrent-клиент, включающий в себя демон, GTK+ и Qt GUI интерфейсы,
# а так же консольный клиент.

# Required:    curl
# Recommended: --- для использования системных библиотек вместо встроенных ---
#              libevent
#              libpsl
#              --- для сборки GTK и QT GUI ---
#              gtkmm3
#              qt5-components
# Optional:    nodejs        (для сборки web-клиента)
#              appindicator  (https://github.com/ubuntu/gnome-shell-extension-appindicator)
#              dht           (https://github.com/jech/dht)
#              libb64        (https://github.com/libb64/libb64)
#              libdeflate    (https://github.com/ebiggers/libdeflate)
#              libnatpmp     (https://github.com/miniupnp/libnatpmp)
#              libutp        (https://github.com/bittorrent/libutp)
#              miniupnp      (https://github.com/miniupnp/miniupnp)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
APPLICATIONS="/usr/share/applications"
PIXMAPS="/usr/share/pixmaps"
mkdir -pv "${TMP_DIR}"{${APPLICATIONS},${PIXMAPS}}

mkdir build
cd build || exit 1

cmake \
    -DCMAKE_INSTALL_PREFIX=/usr                                   \
    -DCMAKE_BUILD_TYPE=Release                                    \
    -DENABLE_CLI=ON                                               \
    -DCMAKE_INSTALL_DOCDIR="/usr/share/doc/${PRGNAME}-${VERSION}" \
    .. || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

# поскольку файл transmission.png отсутствует, создадим его из svg:
rsvg-convert                                               \
   "${TMP_DIR}/usr/share/icons/hicolor/scalable/apps/transmission.svg" \
   -o "${TMP_DIR}/usr/share/pixmaps/transmission.png"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (BitTorrent client)
#
# Transmission is a lightweight open source BitTorrent client, providing useful
# functionality without feature bloat. It consists of a daemon, a GTK+, Qt and
# CLI client.
#
# Home page: https://${PRGNAME}bt.com/
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
