#! /bin/bash

PRGNAME="gnome-keyring"

### GNOME Keyring (a tool to handle security credentials)
# Демон, который хранит и предоставляет доступ к паролям и другим закрытым
# данным пользователей

# Required:    dbus
#              gcr3
# Recommended: linux-pam
#              libxslt
#              openssh
# Optional:    libcap-ng    (https://people.redhat.com/sgrubb/libcap-ng/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим устаревшую запись в шаблоне xml схем
sed -i 's:"/desktop:"/org:' schema/*.xml || exit 1

PAM="false"
command -v pam_namespace_helper &>/dev/null && PAM="true"

mkdir build-gkr
cd build-gkr || exit 1

meson setup ..          \
    --prefix=/usr       \
    --buildtype=release \
    -D systemd=disabled \
    -D ssh-agent=true   \
    -D pam="${PAM}" || exit 1

ninja || exit 1

# для запуска тестов необходима запущенная сессия DBus
# ninja test

DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a tool to handle security credentials)
#
# GNOME Keyring is a program designed to take care of the user's security
# credentials, such as user names and passwords, in an easy to access manner.
# The keyring is implemented as a daemon and uses the process name
# gnome-keyring-daemon.
#
# Home page: https://wiki.gnome.org/Projects/GnomeKeyring
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
