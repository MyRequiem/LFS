#! /bin/bash

PRGNAME="phonon-backend-vlc"

### Phonon-backend-vlc (Phonon backend)
# Серверная часть Phonon, которая использует медиа-инфраструктуру VLC (бэкэнд)

# Required:    phonon
#              vlc      (GUI не обязательно)
# Recommended: no
# Optional:    no

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
    -D PHONON_BUILD_QT5=OFF      \
    .. || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Phonon backend)
#
# Provides a Phonon backend which utilizes the VLC media framework
#
# Home page: https://github.com/KDE/phonon-vlc
# Download:  https://download.kde.org/stable/phonon/${PRGNAME}/${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
