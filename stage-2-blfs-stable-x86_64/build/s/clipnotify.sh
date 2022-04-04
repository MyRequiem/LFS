#! /bin/bash

PRGNAME="clipnotify"

### clipnotify (waits until a new selection is available)
# Простая утилита, которая, используя расширение XFIXES для X11, ожидает пока
# не будет доступен новый выбор для выделения, а затем выходит

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/usr/bin"

gcc \
    clipnotify.c -o clipnotify -lX11 -lXfixes || exit 1

cp clipnotify "${TMP_DIR}/usr/bin"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (waits until a new selection is available)
#
# Is a simple program that, using the XFIXES extension to X11, waits until a
# new selection is available and then exits.
#
# clipnotify doesn't try to print anything about the contents of the selection,
# it just exits when it changes. This is intentional -- X11's selection API is
# verging on the insane, and there are plenty of others who have already lost
# their sanity to bring us xclip/xsel/etc. Use one of those tools to complement
# clipnotify.
#
# Home page: https://github.com/cdown/${PRGNAME}
# Download:  https://github.com/MyRequiem/LFS/raw/master/stage-2-blfs-stable-x86_64/src/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
