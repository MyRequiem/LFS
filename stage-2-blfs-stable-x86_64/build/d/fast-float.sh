#! /bin/bash

PRGNAME="fast-float"
ARCH_NAME="fast_float"

### fast_float (header files for efficient string to float operations)
# Специализированный набор кода (заголовочных файлов) для моментальной
# обработки и преобразования чисел с плавающей запятой из текста в компьютерный
# формат. Это маленькая, но очень важная деталь для ускорения работы программ.

# Required:    cmake
# Recommended: no
# Optional:    git          (для скачивания некоторых тестов)
#              doctest      (https://github.com/doctest/doctest)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

cmake                            \
    -D CMAKE_INSTALL_PREFIX=/usr \
    -D CMAKE_BUILD_TYPE=Release  \
    -G Ninja                     \
    .. || exit 1

### тесты (нужна сеть Internet)
# cmake .. -D FASTFLOAT_TEST=ON && ninja && ninja test

DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (header files for efficient string to float operations)
#
# Fast_float provides a set of C++ header files for efficient string to float
# operations.
#
# Home page: https://github.com/fastfloat/${ARCH_NAME}/
# Download:  https://github.com/fastfloat/${ARCH_NAME}/archive/v${VERSION}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
