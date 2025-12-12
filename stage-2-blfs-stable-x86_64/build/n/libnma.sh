#! /bin/bash

PRGNAME="libnma"

### libnma (NetworkManager GUI client library)
# Библиотека обеспечивающая поддержку NetworkManager, позволяя приложениям
# взаимодействовать с сетевыми настройками и управлять ими через единый
# интерфейс. Это не отдельная программа, а часть системы управления сетью,
# которая позволяет утилитам получать доступ к настройкам Wi-Fi, Ethernet и
# другим сетевым службам.

# Required:    gcr
#              gtk+3
#              iso-codes
#              networkmanager
# Recommended: gtk4
#              vala
# Optional:    mobile-broadband-provider-info    (https://download.gnome.org/sources/mobile-broadband-provider-info)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup ..          \
    --prefix=/usr       \
    --buildtype=release \
    -D gtk_doc=false    \
    -D libnma_gtk4=true \
    -D mobile_broadband_provider_info=false || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (NetworkManager GUI client library)
#
# The libnma package contains an implementation of the NetworkManager GUI
# functions
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
