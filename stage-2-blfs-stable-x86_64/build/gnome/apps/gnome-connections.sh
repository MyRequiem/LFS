#! /bin/bash

PRGNAME="gnome-connections"

### gnome-connections (GNOME Remote Desktop Client)
# Официальное приложение для рабочего стола GNOME, предназначенное для
# удаленного подключения к другим компьютерам или виртуальным машинам,
# используя стандартные протоколы RDP (Remote Desktop Protocol) и VNC (Virtual
# Network Computing), что позволяет легко управлять Linux, Windows и другими
# настольными средами. Это удобный инструмент для доступа к вашему рабочему
# столу из другого места, а также для оказания удаленной технической поддержки.

# Required:    appstream
#              freerdp
#              gtk-vnc
#              itstool
#              libhandy
#              libsecret
#              vala
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup             \
    --prefix=/usr       \
    --buildtype=release \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/help"
rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GNOME Remote Desktop Client)
#
# VNC and RDP client for the GNOME Desktop
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
