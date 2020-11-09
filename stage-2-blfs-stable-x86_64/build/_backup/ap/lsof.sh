#! /bin/bash

PRGNAME="lsof"

### lsof (list open files)
# Утилита для вывода информации о файлах, которые открыты процессами,
# запущенными в системе.

# http://www.linuxfromscratch.org/blfs/view/stable/general/lsof.html

# Home page: https://www.mirrorservice.org/sites/lsof.itap.purdue.edu
# Download:  https://www.mirrorservice.org/sites/lsof.itap.purdue.edu/pub/tools/unix/lsof/lsof_4.91.tar.gz

# Required: libtirpc
# Optional: no

ROOT="/root"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find ${SOURCES} -type f \
    -name "${PRGNAME}_*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d _ -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}_${VERSION}"*.tar.?z* || exit 1
cd "${PRGNAME}_${VERSION}" || exit 1
tar xvf "${PRGNAME}_${VERSION}_src.tar"
cd "${PRGNAME}_${VERSION}_src" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
MAN="/usr/share/man/man8"
mkdir -pv "${TMP_DIR}"{/usr/bin,${MAN}}

./Configure -n linux || exit 1

# в команду 'make' добавляем расположение библиотек libtirpc
make CFGL="-L./lib -ltirpc"

# пакет не имеет набора тестов

install -v -m0755 -o root -g root lsof /usr/bin
install -v -m0755 -o root -g root lsof "${TMP_DIR}/usr/bin"

install -v lsof.8 "${MAN}"
install -v lsof.8 "${TMP_DIR}${MAN}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (list open files)
#
# Lsof is a Unix-specific tool. Its name stands for "LiSt Open Files", and it
# does just that. It lists information about files that are open by the
# processes running on the system.
#
# Home page: https://www.mirrorservice.org/sites/lsof.itap.purdue.edu
# Download:  https://www.mirrorservice.org/sites/lsof.itap.purdue.edu/pub/tools/unix/${PRGNAME}/${PRGNAME}_${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
