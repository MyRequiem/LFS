#! /bin/bash

PRGNAME="patchelf"

### Patchelf (tool to modify ELF binaries/libraries)
# Утилита для изменения существующего исполняемого файла или ELF библиотеки. С
# ее помощью можно изменить динамический загрузчик (интерпретатор ELF)
# исполняемого файла, RPATH и добавлять/изменять/удалять объявленные
# зависимости от динамических библиотек.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (tool to modify ELF binaries/libraries)
#
# PatchELF is a utility for modifying an existing ELF executable or library. It
# can change the dynamic loader ("ELF interpreter") of an executable, modify
# the RPATH, and add/change/remove declared dependencies on dynamic libraries.
#
# Home page: https://github.com/NixOS/${PRGNAME}
# Download:  https://github.com/NixOS/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
