#! /bin/bash

PRGNAME="libevent"

### libevent (event loop library)
# Библиотека обеспечивающая асинхронное уведомление о событиях. Libevent API
# предоставляет механизм выполнения функции callback, когда конкретное событие
# происходит в файловом дескрипторе или по истечении времени ожидания. libevent
# также поддерживает обратные вызовы, запускаемые сигналами и регулярными
# тайм-аутами.

# Required:    no
# Recommended: no
# Optional:    doxygen (для сборки API-документации)

ROOT="/root/src/lfs"
SOURCES="${ROOT}/src"
source "${ROOT}/check_environment.sh" || exit 1

VERSION="$(find ${SOURCES} -type f \
    -name "${PRGNAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | rev | \
    cut -d . -f 3- | cut -d - -f 2 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}-${VERSION}-stable"*.tar.?z* || exit 1
cd "${PRGNAME}-${VERSION}-stable" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

DOXYGEN="--disable-doxygen-doc"
API_DOCS=""
# command -v doxygen &>/dev/null && \
#     DOXYGEN="--enable-doxygen-doc" && API_DOCS="true"

./configure       \
    --prefix=/usr \
    "${DOXYGEN}"  \
    --disable-static || exit 1

make || exit 1

[ -n "${API_DOCS}" ] && doxygen Doxyfile

# # тесты
# make verify

make install DESTDIR="${TMP_DIR}"

if [ -n "${API_DOCS}" ]; then
    DOCS="/usr/share/doc/${PRGNAME}-${VERSION}/api"
    install -v -m755 -d "${TMP_DIR}${DOCS}"
    cp -v -R doxygen/html/* "${TMP_DIR}${DOCS}"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (event loop library)
#
# libevent is meant to replace the event loop found in event driven network
# servers. An application just needs to call event_dispatch() and then add or
# remove events dynamically without having to change the event loop. The
# libevent API provides a mechanism to execute a callback function when a
# specific event occurs on a file descriptor or after a timeout has been
# reached.
#
# Home page: https://libevent.org/
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/releases/download/release-${VERSION}-stable/${PRGNAME}-${VERSION}-stable.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
