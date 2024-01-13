#! /bin/bash

PRGNAME="xsel"

### XSel (program for getting/setting the contents of the X selection)
# Утилита командной строки для получения содержимого выделения в X и его
# помещения/вставки в/из clipboard

# Required:    Graphical Environments
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# по умолчанию все предупреждения в процессе компиляции считаются ошибками
# (-Werror in released code), исправим это
sed -i 's,-Werror,,g' configure || exit 1

./configure       \
    --prefix=/usr \
    --with-x || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (program for getting/setting the contents of the X selection)
#
# XSel is a command-line program for getting and setting the contents of the X
# selection. Normally this is only accessible by manually highlighting
# information and pasting it with the middle mouse button.
#
# Home page: http://www.vergenet.net/~conrad/software/${PRGNAME}/
# Download:  http://www.vergenet.net/~conrad/software/${PRGNAME}/download/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
