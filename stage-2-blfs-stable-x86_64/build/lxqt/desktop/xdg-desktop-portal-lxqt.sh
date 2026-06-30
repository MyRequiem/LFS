#! /bin/bash

PRGNAME="xdg-desktop-portal-lxqt"

### xdg-desktop-portal-lxqt (backend for xdg-desktop-portal that is using Qt)
# Специализированный программный портал, созданный для интеграции изолированных
# приложений в графическую среду LXQt. Он позволяет программам из контейнеров
# Flatpak или Snap безопасно открывать файлы и выводить уведомления.

# Required:    libfm-qt
#              kwindowsystem или kde-frameworks
#              xdg-desktop-portal                   (runtime)
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
    -D CMAKE_INSTALL_PREFIX=/usr \
    -D CMAKE_BUILD_TYPE=Release || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

# удалим systemd модуль, который бесполезен в нашей SysVinit системе
rm -rf "${TMP_DIR}/usr/lib/systemd"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (backend for xdg-desktop-portal that is using Qt)
#
# xdg-desktop-portal-lxqt is a backend for xdg-desktop-portal, that is using
# the Qt library
#
# Home page: https://github.com/lxqt/${PRGNAME}/
# Download:  https://github.com/lxqt/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
