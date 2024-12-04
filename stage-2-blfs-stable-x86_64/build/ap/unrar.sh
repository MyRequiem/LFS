#! /bin/bash

PRGNAME="unrar"
ARCH_NAME="${PRGNAME}src"

### UnRar (Extract, test and view RAR archives)
# Бесплатная утилита, распространяемая с исходным кодом, предназначенная для
# извлечения, тестирования и просмотра содержимого архивов, созданных с помощью
# архиватора RAR версии 1.50 и выше. Библиотека UnRAR является второстепенной
# частью архиватора RAR и содержит алгоритм сжатия RAR. Библиотека UnRAR также
# может использоваться другими программами для извлечения RAR-архивов.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find ${SOURCES} -type f \
    -name "${ARCH_NAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${ARCH_NAME}-${VERSION}"*.tar.?z* || exit 1
cd "${PRGNAME}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/usr/"{bin,lib,"include/${PRGNAME}"}

# изменим имя библитеки libunrar.so (by default) на libunrar.so.${VERSION}
patch -p1 --verbose < "${SOURCES}/${PRGNAME}-${VERSION}-soname.patch" || exit 1

# копируем дерево исходников в директорию libunrar для сборки библиотеки
cp -av . ../libunrar

# собираем и устанавливаем unrar и libunrar.so.${VERSION}
make -f makefile                                || exit 1
make -C ../libunrar lib libversion="${VERSION}" || exit 1

install -vm 755 "${PRGNAME}" "${TMP_DIR}/usr/bin/${PRGNAME}"
install -vm 755 "../libunrar/libunrar.so.${VERSION}" \
    "${TMP_DIR}/usr/lib/libunrar.so.${VERSION}"

# ссылки в /usr/lib/
#    libunrar.so.6 -> libunrar.so.6.2.6
#    libunrar.so   -> libunrar.so.6
#    libunrar.so.5 -> libunrar.so.6 (для совместимости)
(
  cd "${TMP_DIR}/usr/lib" || exit 1
  MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1)"
  ln -sv "libunrar.so.${VERSION}" "libunrar.so.${MAJ_VERSION}"
  ln -sv "libunrar.so.${MAJ_VERSION}" libunrar.so
  ln -sv "libunrar.so.${MAJ_VERSION}" libunrar.so.5
)

install -vm 644 dll.hpp "${TMP_DIR}/usr/include/${PRGNAME}/dll.hpp"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Extract, test and view RAR archives)
#
# The UnRAR utility is a freeware program, distributed with source code and
# developed for extracting, testing and viewing the contents of archives
# created with the RAR archiver version 1.50 and above. The UnRAR library is a
# minor part of the RAR archiver and contains the RAR uncompression algorithm.
# UnRAR requires very small volume of memory to operate. The UnRAR library can
# also be used by other programs to extract RAR archives.
#
# Home page: https://www.rarlab.com/rar_add.htm
# Download:  https://www.rarlab.com/rar/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
