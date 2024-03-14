#! /bin/bash

PRGNAME="lsof"

### lsof (list open files)
# Утилита для вывода информации о файлах, которые открыты процессами,
# запущенными в системе.

# Required:    libtirpc
# Recommended: no
# Optional:    nmap (для тестов)

### Конфигурация ядра (для запуска тестов)
#    CONFIG_POSIX_MQUEUE=y

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find ${SOURCES} -type f \
    -name "${PRGNAME}_*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 4- | cut -d _ -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}_${VERSION}"*.tar.?z* || exit 1
cd "${PRGNAME}_${VERSION}"* || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
MAN="/usr/share/man/man8"
mkdir -pv "${TMP_DIR}"{/usr/bin,${MAN}}

./Configure -n linux || exit 1
make || exit 1
# make check

install -v -m0755 -o root -g root lsof "${TMP_DIR}/usr/bin"
install -v lsof.8 "${TMP_DIR}${MAN}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (list open files)
#
# Lsof is a Unix-specific tool. Its name stands for "LiSt Open Files", and it
# does just that. It lists information about files that are open by the
# processes running on the system.
#
# Home page: https://github.com/${PRGNAME}-org/${PRGNAME}/
# Download:  https://github.com/${PRGNAME}-org/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}_${VERSION}.linux.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
