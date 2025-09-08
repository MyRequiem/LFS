#! /bin/bash

PRGNAME="tuxguitar"

### TuxGuitar (A Multitrack tablature editor and player)
# Приложение для редактирования и проигрывания гитарных табулатур в формате
# GuitarPro, PowerTab, and TablEdit написанное на Java-SWT (Standard Widget
# Toolkit)

# Required:    openjdk
#              lilv     (https://drobilla.net/software/lilv)
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${PRGNAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 4 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}-${VERSION}"*.tar.?z* || exit 1
cd "${PRGNAME}-${VERSION}-linux-swt-amd64" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/"{usr/{bin,share/{applications,pixmaps}},"opt/${PRGNAME}"}

cp -vR ./* "${TMP_DIR}/opt/${PRGNAME}"

(
    # /usr/bin/tuxguitar -> /opt/tuxguitar/tuxguitar.sh
    cd "${TMP_DIR}/usr/bin" || exit 1
    ln -svf "../../opt/${PRGNAME}/${PRGNAME}.sh" "${PRGNAME}"

    # /usr/share/applications/tuxguitar.desktop ->
    #    /opt/tuxguitar/share/applications/tuxguitar.desktop
    cd "${TMP_DIR}/usr/share/applications" || exit 1
    ln -svf "../../../opt/${PRGNAME}/share/applications/${PRGNAME}.desktop" \
        "${PRGNAME}.desktop"

    # /usr/share/pixmaps/tuxguitar.png -> \
    #    /opt/tuxguitar/share/pixmaps/tuxguitar.png
    cd "${TMP_DIR}/usr/share/pixmaps" || exit 1
    ln -svf "../../../opt/${PRGNAME}/share/pixmaps/${PRGNAME}.png" \
        "${PRGNAME}.png"
)

chmod +x "${TMP_DIR}/opt/${PRGNAME}/lib/lib${PRGNAME}-"*.so

mv $"${TMP_DIR}/opt/${PRGNAME}/share/man" "${TMP_DIR}/usr/share/"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (A Multitrack tablature editor and player)
#
# TuxGuitar is a multitrack guitar tablature editor and player written in
# Java-SWT. It can open GuitarPro, PowerTab, and TablEdit files.
#
# Home page: https://www.${PRGNAME}.app/
# Download:  https://github.com/helge17/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}-linux-swt-amd64.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
