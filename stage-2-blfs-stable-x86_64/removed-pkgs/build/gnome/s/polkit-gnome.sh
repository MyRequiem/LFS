#! /bin/bash

PRGNAME="polkit-gnome"

### polkit-gnome (GTK+ authentication agent for polkit)
# Предоставляет агент аутентификации для Polkit, который хорошо интегрируется
# со средой рабочего стола GNOME

# Required:    accountsservice
#              gtk+3
#              polkit
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
AUTOSTART="/etc/xdg/autostart"
mkdir -pv "${TMP_DIR}${AUTOSTART}"

# некоторые исправления безопасности
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-consolidated_fixes-1.patch"

./configure \
    --prefix=/usr || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

AGENT="${TMP_DIR}${AUTOSTART}/${PRGNAME}-authentication-agent-1.desktop"
cat << EOF > "${AGENT}"
[Desktop Entry]
Name=PolicyKit Authentication Agent
Comment=PolicyKit Authentication Agent
Exec=/usr/libexec/${PRGNAME}-authentication-agent-1
Terminal=false
Type=Application
Categories=
NoDisplay=true
OnlyShowIn=GNOME;XFCE;Unity;
AutostartCondition=GNOME3 unless-session gnome
EOF

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GTK+ authentication agent for polkit)
#
# The Polkit GNOME package provides an Authentication Agent for Polkit that
# integrates well with the GNOME Desktop environment
#
# Home page: https://download.gnome.org/sources/${PRGNAME}/
# Download:  https://download.gnome.org/sources/${PRGNAME}/${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
