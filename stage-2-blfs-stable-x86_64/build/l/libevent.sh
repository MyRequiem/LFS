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

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим shebang для event_rpcgen.py
#    #!/usr/bin/env python -> #!/usr/bin/env python3
sed -i 's/python/&3/' event_rpcgen.py || exit 1

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1

# тесты
# make verify

make install DESTDIR="${TMP_DIR}"

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
