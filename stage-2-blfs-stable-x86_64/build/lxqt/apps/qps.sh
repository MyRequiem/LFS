#! /bin/bash

PRGNAME="qps"

### qps (Qt process manager)
# Полнофункциональный визуальный диспетчер задач и системный монитор,
# отображающий текущие процессы в виде подробной таблицы. Он помогает быстро
# находить программы, которые перегружают процессор или занимают много памяти.

# Required:    liblxqt
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

cmake ..                         \
    -D CMAKE_BUILD_TYPE=Release  \
    -D CMAKE_INSTALL_PREFIX=/usr || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

xdg-icon-resource forceupdate --theme hicolor || exit 1

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Qt process manager)
#
# The qps package contains a Qt process manager
#
# Home page: https://github.com/lxqt/${PRGNAME}/
# Download:  https://github.com/lxqt/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
