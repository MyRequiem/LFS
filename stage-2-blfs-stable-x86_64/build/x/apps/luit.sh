#! /bin/bash

PRGNAME="luit"

### luit (character encoding convertor for X11 terminals)
# Фильтр, который можно запускать между приложением и UTF-8 эмулятором
# терминала, например xterm. Он преобразует вывод приложения из кодировки
# локали в UTF-8 и конвертирует ввод терминала из UTF-8 в кодировку локали

# Required:    xorg-applications
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/xorg_config.sh"                        || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# shellcheck disable=SC2086
./configure \
    ${XORG_CONFIG} || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (character encoding convertor for X11 terminals)
#
# Luit is a filter that can be run between an arbitrary application and a UTF-8
# terminal emulator such as xterm. It will convert application output from the
# locale's encoding into UTF-8, and convert terminal input from UTF-8 into the
# locale's encoding
#
# Home page: https://www.x.org/
# Download:  https://invisible-mirror.net/archives/${PRGNAME}/${PRGNAME}-${VERSION}.tgz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
