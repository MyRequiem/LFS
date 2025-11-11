#! /bin/bash

PRGNAME="pm-utils"

### pm-utils (The Power Management Utilities)
# Утилиты управления питанием - простые инструменты командной строки для
# приостановки работы компьютера и перевода его в спящие режимы: suspend,
# hibernate, suspend-hybrid

# Required:    no
# Recommended: no
# Optional:    xmlto            (для пересборки man-страниц)
#              --- runtime ---
#              hdparm
#              wireless-tools
#              ethtool          (https://www.kernel.org/pub/software/network/ethtool/)
#              vbetool          (https://ftp.debian.org/debian/pool/main/v/vbetool/)

### Конфигурация ядра
#    CONFIG_SUSPEND=y
#    CONFIG_HIBERNATION=y

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/usr/share/man"/{man1,man8}

# исправим несколько ошибок и пару несовместимостей с новыми ядрами
patch --verbose -Np1 \
    -i "${SOURCES}/${PRGNAME}-${VERSION}-bugfixes-1.patch" || exit 1

./configure           \
    --prefix=/usr     \
    --sysconfdir=/etc \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

# man-страницы
install -v -m644 man/*.1 "${TMP_DIR}/usr/share/man/man1"
install -v -m644 man/*.8 "${TMP_DIR}/usr/share/man/man8"
ln -sv pm-action.8       "${TMP_DIR}/usr/share/man/man8/pm-suspend.8"
ln -sv pm-action.8       "${TMP_DIR}/usr/share/man/man8/pm-hibernate.8"
ln -sv pm-action.8       "${TMP_DIR}/usr/share/man/man8/pm-suspend-hybrid.8"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (The Power Management Utilities)
#
# The Power Management Utilities provide simple shell command line tools to
# suspend and hibernate the computer. They can be used to run user supplied
# scripts on suspend and resume.
#
# Home page: https://${PRGNAME}.freedesktop.org/
# Download:  https://${PRGNAME}.freedesktop.org/releases/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
