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

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/usr/"{bin,lib,include/unrar}

# библиотека должна создаваться в виде libunrar.so.${VERSION}
# (по умолчанию создается libunrar.so)
sed -e "s#.*-shared -o libunrar.so.*#\t\$(LINK) -shared -Wl,-soname,libunrar.so.\$(libversion) -o libunrar.so.\$(libversion) \$(LDFLAGS) \$(OBJECTS) \$(LIB_OBJ)#" -i makefile || exit 1

# копируем дерево исходников в директорию libunrar для сборки библиотеки
cp -av . ../libunrar

# собираем libunrar.so.${VERSION}
make -C ../libunrar lib libversion="${VERSION}" || exit 1

# собираем unrar
make -f makefile || exit 1

# пакет не содержит набора тестов

install -vm 755 unrar "${TMP_DIR}/usr/bin/unrar"

install -vm 755 "../libunrar/libunrar.so.${VERSION}" \
    "${TMP_DIR}/usr/lib/libunrar.so.${VERSION}"

(
  cd "${TMP_DIR}/usr/lib" || exit 1
  MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1)"
  ln -sv "libunrar.so.${VERSION}" "libunrar.so.${MAJ_VERSION}"
  ln -sv "libunrar.so.${MAJ_VERSION}" libunrar.so
)

cp -a ./*.cpp ./*.hpp "${TMP_DIR}/usr/include/unrar/"

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
# Download:  http://www.rarlab.com/rar/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
