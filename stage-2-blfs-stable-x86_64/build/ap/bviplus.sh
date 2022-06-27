#! /bin/bash

PRGNAME="bviplus"

### Bviplus (hex editor with vi-style user interface)
# Hex-редактор на основе ncurses с интерфейсом и привязками клавиш в стиле Vim

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
MANDIR="/usr/share/man/man1"
mkdir -pv "${TMP_DIR}"{/usr/bin,"${MANDIR}"}

# исправим ошибку сборки
sed -i 's,\<inline\>,,'                 ./*.c ./*.h   || exit 1
# исправим предупреждения
sed -i '/int *is_bin(c)/s,\<c\>,int c,' key_handler.c || exit 1
# не выводим отладку при запуске
sed -i '/printf.*argv\[%d\]/d'          main.c        || exit 1

make    \
    V=1 \
    EXTRA_CFLAGS="-Wall -Wno-unused -O2 -fPIC -Wl,-s"

cp -a "${PRGNAME}" "${TMP_DIR}/usr/bin"

# man-страница от B. Watson (urchlay@slackware.uk)
# https://slackbuilds.org/repository/15.0/development/bviplus/
cp "${SOURCES}/${PRGNAME}.1" "${TMP_DIR}${MANDIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (hex editor with vi-style user interface)
#
# Bviplus is an ncurses based hex editor with a vim-like interface. It was
# originally a fork of Binary VIsual editor (bvi) by Gerhard Burgmann, but has
# now been completely rewritten (since version 0.3)
#
# Home page: http://${PRGNAME}.sourceforge.net/
# Download:  https://downloads.sourceforge.net/project/${PRGNAME}/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tgz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
