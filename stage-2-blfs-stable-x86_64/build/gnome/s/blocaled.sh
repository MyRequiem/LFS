#! /bin/bash

PRGNAME="blocaled"

### blocaled (localed D-Bus service)
# Реализация протокола D-Bus org.freedesktop.locale1, который обычно
# поставляется с systemd, но необходим для рабочего стола GNOME

# Required:    polkit
#              libdaemon
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
PROFILE_D="/etc/profile.d"
mkdir -pv "${TMP_DIR}${PROFILE_D}"

./configure       \
    --prefix=/usr \
    --sysconfdir=/etc || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (localed D-Bus service)
#
# blocaled is an implementation of the org.freedesktop.locale1 D-Bus protocol,
# which normally comes with systemd. It is needed by the GNOME desktop
#
# Home page: https://github.com/lfs-book/${PRGNAME}/
# Download:  https://github.com/lfs-book/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
