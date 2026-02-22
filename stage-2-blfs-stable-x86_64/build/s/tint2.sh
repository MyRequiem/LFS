#! /bin/bash

PRGNAME="tint2"

### tint2 (panel/taskbar for modern X window managers)
# Легкая, минималистичная панель задач для современных оконных менеджеров X, но
# специально созданная для Openbox3

# Required:    cmake
#              imlib2
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

# решим проблему с libm.so (glibc) и ошибкой "DSO missing" на стадии линковки
#    LDFLAGS="-lm"
# обеспечим совместимость со свежим CMake 4.x.x
#    CMAKE_POLICY_VERSION_MINIMUM=3.5
# не нужно мусорить в логе/выводе предупреждениями для разработчиков :)
#    -W no-dev
LDFLAGS="-lm" \
cmake                                   \
    -D CMAKE_INSTALL_PREFIX=/usr        \
    -D CMAKE_BUILD_TYPE=Release         \
    -D CMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -W no-dev                           \
    .. || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (panel/taskbar for modern X window managers)
#
# tint2 is a simple panel/taskbar intentionally made for openbox3, but should
# also work with other window managers
#
# Home page: https://gitlab.com/nick87720z/${PRGNAME}
# Download:  https://gitlab.com/nick87720z/${PRGNAME}/-/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
