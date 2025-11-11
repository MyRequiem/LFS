#! /bin/bash

PRGNAME="openoffice"
ARCH_NAME="Apache_OpenOffice"
BUILD_ID="9813"

### OpenOffice (a full-featured open-source office suite)
# Бесплатный кроссплатформенный офисный пакет с открытым исходным кодом,
# включающий текстовый процессор, редактор электронных таблиц, программу для
# создания презентаций, векторный редактор, систему управления базами данных и
# редактор формул

# Required:    --- только для сборки ---
#              cpio
#              rpm
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${ARCH_NAME}_*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d _ -f 5 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/usr/"{bin,share/applications}

tar xvf "${SOURCES}/${ARCH_NAME}_"*.tar.?z* || exit 1
SOURCEDIR="${BUILD_DIR}/ru/RPMS"
cd "${SOURCEDIR}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

# нам не нужен onlineupdate
rm -vf ./*onlineupdate*.rpm

# извлечем все .rpm архивы
for FILE in *.rpm ; do
    rpm2cpio < "${FILE}" | cpio -imdv
done

cd desktop-integration || exit 1
MENU="${PRGNAME}${VERSION}-freedesktop-menus-${VERSION}-${BUILD_ID}.noarch.rpm"
rpm2cpio < "${MENU}" | cpio -imdv
cd .. || exit 1

mv opt "${TMP_DIR}"
cd "${TMP_DIR}" || exit 1

# ссылки в /usr/bin на реальные бинарники
MAJVER=$(echo "${VERSION}" | cut -d . -f 1)
cd usr/bin/ || exit 1
for FILE in sbase scalc sdraw simpress smath soffice spadmin swriter unopkg ; do
    rm -f "${FILE}"
    ln -sfv "../../opt/${PRGNAME}${MAJVER}/program/${FILE}" "open-${FILE}"
done
# shellcheck disable=SC2164
cd -

# исправим скрипты, чтобы они не конфликтовали с другими производными soffice
cd "opt/${PRGNAME}${MAJVER}/program" || exit 1
for FILE in sbase scalc sdraw simpress smath spadmin swriter unopkg; do
    sed -i 's/soffice/open-soffice/' "${FILE}"
done
ln -sv soffice.bin open-soffice.bin
# shellcheck disable=SC2164
cd -

cat << EOF > "usr/bin/${PRGNAME}${MAJVER}"
#!/bin/sh
/opt/${PRGNAME}${MAJVER}/program/soffice "\$@"
EOF
chmod 755 "usr/bin/${PRGNAME}${MAJVER}"

# desktop files
for APP in base calc draw impress math writer; do
    cp -av "opt/${PRGNAME}${MAJVER}/share/xdg/${APP}.desktop" \
        "usr/share/applications/open-${APP}.desktop"
done

# menu icons
cp -R "${SOURCEDIR}/desktop-integration/usr/share/icons" "${TMP_DIR}/usr/share/"
# по умолчанию меню отдельное, т.е. writer, math и т.д. Сделаем вложенное
# раскрывающееся меню Office, в нем OpenOffice а уже в нем writer, math ...
# https://slackalaxy.com/wp-content/uploads/2021/08/spg5.png
mkdir -p etc/xdg/menus/applications-merged
cp "${SOURCES}/${PRGNAME}.menu" etc/xdg/menus/applications-merged

mkdir -p usr/share/desktop-directories
cp "${SOURCES}/${PRGNAME}.directory" usr/share/desktop-directories

# категория в файлах .desktop закомментируем, чтобы избежать дублирования
sed -i "s:Categories:#Categories:" usr/share/applications/*.desktop

# удалим бесполезную документацию
rm -rf "opt/${PRGNAME}${MAJVER}"/{readmes,share/readme}

### Вот такой костыль :)
# при запуске OpenOffice хочет libcrypt.so.1, у нас в системе libcrypt.so.2
#    libcrypt.so.2 -> libcrypt.so.2.0.0 (пакет libxcrypt)
# пришлось взять со Slackware-15.0
#    /usr/lib/libcrypt.so.1 -> libcrypt-2.33.so
mkdir -p "${TMP_DIR}/usr/lib"
cp "${SOURCES}/libcrypt-2.33.so" "${TMP_DIR}/usr/lib/"
ln -s libcrypt-2.33.so "${TMP_DIR}/usr/lib/libcrypt.so.1"
chmod 755 "${TMP_DIR}/usr/lib/libcrypt-2.33.so"

# fix permissions
find "${TMP_DIR}" '(' -name "*.so" -o -name "*.so.*" ')' -exec chmod +x {} \;
chmod -R u+rw,go+r-w,a-s .

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a full-featured open-source office suite)
#
# OpenOffice.org is a full-featured open-source office suite that is compatible
# with all other major office software
#
# Home page: https://www.${PRGNAME}.org/
# Download:  https://sourceforge.net/projects/${PRGNAME}org.mirror/files/${VERSION}/binaries/ru/${ARCH_NAME}_${VERSION}_Linux_x86-64_install-rpm_ru.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
