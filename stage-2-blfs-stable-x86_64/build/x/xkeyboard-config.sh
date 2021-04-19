#! /bin/bash

PRGNAME="xkeyboard-config"

### XKeyboardConfig (X Keyboard Extension config files)
# База данных конфигурации клавиатуры для X Window System

# Required:    xorg-libraries
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/xorg_config.sh"                        || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# По умолчанию установленные правила XKB называются 'base'. В директории
# /usr/share/X11/xkb/rules/ мы создаем символические ссылки с именем 'xorg' на
# эти правила, что для Xorg является именем по умолчанию:
#    xorg     -> base
#    xorg.lst -> base.lst
#    xorg.xml -> base.xml
#
#    --with-xkb-rules-symlink=xorg
#
# shellcheck disable=SC2086
./configure        \
    ${XORG_CONFIG} \
    --with-xkb-rules-symlink=xorg || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (X Keyboard Extension config files and)
#
# The XKeyboardConfig package contains the keyboard configuration database for
# the X Window System.
#
# Home page: https://www.x.org
# Download:  https://www.x.org/pub/individual/data/${PRGNAME}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
