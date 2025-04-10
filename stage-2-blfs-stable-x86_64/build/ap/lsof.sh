#! /bin/bash

PRGNAME="lsof"

### lsof (list open files)
# Утилита для вывода информации о файлах, которые открыты процессами,
# запущенными в системе.

# Required:    libtirpc
# Recommended: no
# Optional:    nmap     (для тестов)

### Конфигурация ядра (для запуска тестов)
#    CONFIG_POSIX_MQUEUE=y

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (list open files)
#
# Lsof is a Unix-specific tool. Its name stands for "LiSt Open Files", and it
# does just that. It lists information about files that are open by the
# processes running on the system.
#
# Home page: https://github.com/${PRGNAME}-org/${PRGNAME}/
# Download:  https://github.com/${PRGNAME}-org/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
