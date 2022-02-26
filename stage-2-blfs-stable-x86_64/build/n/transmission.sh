#! /bin/bash

PRGNAME="transmission"

### Transmission (BitTorrent client)
# Легкий BitTorrent-клиент, включающий в себя демон, GTK+ и Qt GUI интерфейсы,
# а так же консольный клиент.

# Required:    curl
#              libevent
# Recommended: gtk+3 (для сборки GTK GUI)
#              qt5   (для сборки QT GUI)
# Optional:    doxygen
#              gdb

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
APPLICATIONS="/usr/share/applications"
PIXMAPS="/usr/share/pixmaps"
mkdir -pv "${TMP_DIR}"{${APPLICATIONS},${PIXMAPS}}

GTK3="--without-gtk"
QT5="false"

command -v gtk3-demo          && GTK3="--with-gtk"
[ -x /opt/qt5/bin/assistant ] && QT5="true"

./configure       \
    --prefix=/usr \
    "${GTK3}"     \
    --enable-cli || exit 1

make || exit 1

# собираем QT GUI
if [[ "x${QT5}" == "xtrue"  ]]; then
    pushd qt || exit 1
    qmake qtr.pro || exit 1
    make          || exit 1
    popd || exit 1
fi

# пакет не имеет набора тестов

make install DESTDIR="${TMP_DIR}"

if [[ "x${QT5}" == "xtrue"  ]]; then
    make INSTALL_ROOT="${TMP_DIR}/usr" -C qt install
fi

install -m644 qt/${PRGNAME}-qt.desktop \
    "${TMP_DIR}${APPLICATIONS}/${PRGNAME}-qt.desktop"
install -m644 qt/icons/${PRGNAME}.png  \
    "${TMP_DIR}${PIXMAPS}/${PRGNAME}-qt.png"

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
# Download:  https://raw.githubusercontent.com/${PRGNAME}/${PRGNAME}-releases/master/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
