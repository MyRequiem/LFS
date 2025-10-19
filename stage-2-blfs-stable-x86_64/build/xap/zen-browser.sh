#! /bin/bash

PRGNAME="zen-browser"
ARCH_NAME="zen.linux-x86_64"

### Zen Browser (web browser)
# Красиво оформленный, ориентированный на конфиденциальность и оснащенный
# множеством функций веб-браузер.

# Required:    qt5-components
#              qt6
#              nss
#              cups
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
! [ -e "${SOURCES}/${ARCH_NAME}.tar.xz" ] && {
    echo "Archive ${SOURCES}/${ARCH_NAME} not found..."
    echo "Download: https://github.com/${PRGNAME}/desktop/releases/latest/download/${ARCH_NAME}.tar.xz"
    exit 1
}

INSTALLED_VER=$(find /var/log/packages/ -type f -name "${PRGNAME}-*" | \
    rev |  cut -f 1 -d - | rev)
echo -en "Installed version: ${INSTALLED_VER}\nTarball version:   "

# shellcheck disable=SC2002
VERSION=$(tar -xJf ${SOURCES}/${ARCH_NAME}.tar.xz zen/application.ini && \
    cat zen/application.ini | grep -e '^Version' | cut -d = -f 2)
rm -rf ./zen/
echo "${VERSION}"

echo -ne "\nContinue? [y/N]: "
read -r YESNO
[ "${YESNO}" != "y" ] && exit 0

# удаляем установленную версию
[ -n "${INSTALLED_VER}" ] && \
    yes | /sbin/removepkg "/var/log/packages/${PRGNAME}-${INSTALLED_VER}"

TMP_DIR="/tmp/package-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/"{opt,usr/{bin,share/{applications,pixmaps}}}
cd "${TMP_DIR}" || exit 1

tar xvf "${SOURCES}/${ARCH_NAME}.tar.xz" || exit 1
mv zen "${PRGNAME}"
mv "${PRGNAME}" "${TMP_DIR}/opt"

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

ln -s "../../opt/${PRGNAME}/zen" "${TMP_DIR}/usr/bin/${PRGNAME}"

cat << EOF > "${TMP_DIR}/usr/share/applications/${PRGNAME}.desktop"
[Desktop Entry]
Comment=Zen Web Browser
Name=Zen Browser
GenericName=Zen Browser
Exec=${PRGNAME}
Categories=Network;X-XFCE;X-Xfce-Toplevel;
Icon=${PRGNAME}
StartupNotify=true
Terminal=false
Type=Application
MimeType=application/pdf;application/rdf+xml;application/rss+xml;application/xhtml+xml;application/xhtml_xml;application/xml;image/gif;image/jpeg;image/png;image/webp;text/html;text/xml;x-scheme-handler/http;x-scheme-handler/https;
EOF

cp "${TMP_DIR}/opt/${PRGNAME}/browser/chrome/icons/default/default128.png" \
    "${TMP_DIR}/usr/share/pixmaps/${PRGNAME}.png"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (web browser)
#
# Beautifully designed, privacy-focused, and packed with features. It cares
# about your experience, not your data.
#
# Home page: https://${PRGNAME}.app/
# Download:  https://github.com/${PRGNAME}/desktop/releases/latest/download/${ARCH_NAME}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
