#! /bin/bash

PRGNAME="google-chrome"
ARCH_NAME="${PRGNAME}-stable_current_amd64.deb"

### Google Chrome (Google Chrome web browser)
# Веб-браузер от Google

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
! [ -e "${SOURCES}/${ARCH_NAME}" ] && {
    echo "Archive ${SOURCES}/${ARCH_NAME} not found..."
    exit 1
}

INSTALLED_VER=$(find /var/log/packages/ -type f -name "${PRGNAME}-*" | \
    rev |  cut -f 1 -d - | rev)
echo -en "Installed version: ${INSTALLED_VER}\nTarball version:   "

VERSION=$(ar p "${SOURCES}/${ARCH_NAME}" control.tar.xz 2> /dev/null | \
    tar -JxO ./control | grep Version | awk '{print $2}' | cut -d - -f 1)
echo "${VERSION}"

echo -ne "\nContinue? [y/N]: "
read -r YESNO
[ "${YESNO}" != "y" ] && exit 0

# удаляем установленную версию
[ -n "${INSTALLED_VER}" ] && \
    yes | /sbin/removepkg "/var/log/packages/${PRGNAME}-${INSTALLED_VER}"

TMP_DIR="/tmp/build-package-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

cd "${TMP_DIR}" || exit 1
ar p "${SOURCES}/${ARCH_NAME}" data.tar.xz | tar xJv || exit 1
chown -R root:root .
chmod -R u+w,go+r-w,a-s .

# расписание cron предназначено только для Debian/Ubuntu
rm -rf etc

chmod 0755 .
chmod 4711 opt/google/chrome/chrome-sandbox

# ссылки на стандартные названия библиотек mozilla
sed -i 's,libnss3.so.1d,libnss3.so\x00\x00\x00,g;
        s,libnssutil3.so.1d,libnssutil3.so\x00\x00\x00,g;
        s,libsmime3.so.1d,libsmime3.so\x00\x00\x00,g;
        s,libssl3.so.1d,libssl3.so\x00\x00\x00,g;
        s,libplds4.so.0d,libplds4.so\x00\x00\x00,g;
        s,libplc4.so.0d,libplc4.so\x00\x00\x00,g;
        s,libnspr4.so.0d,libnspr4.so\x00\x00\x00,g;' \
        opt/google/chrome/chrome || exit 1

mv usr/bin/{"${PRGNAME}-stable","${PRGNAME}"} || exit 1

# .desktop
sed -e "s#Icon=${PRGNAME}#Icon=/opt/google/chrome/product_logo_256.png#" \
    -e "s#${PRGNAME}-stable#${PRGNAME}#"                                 \
           -i usr/share/applications/${PRGNAME}.desktop || exit 1

# удалим документацию и menu
rm -rf "${TMP_DIR}/usr/share/"{doc,menu}

# man-страница
(
    cd "${TMP_DIR}/usr/share/man/man1"
    rm -f "${PRGNAME}.1.gz"
    gunzip "${PRGNAME}-stable.1.gz"
    mv "${PRGNAME}-stable.1" "${PRGNAME}.1"
) || exit 1

/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Google Chrome web browser)
#
# Google Chrome is a web browser that combines a minimal design with
# sophisticated technology to make the web faster, safer, and easier.
#
# Home page: https://www.google.com/chrome
# Download:  https://dl.google.com/linux/direct/${ARCH_NAME}
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
