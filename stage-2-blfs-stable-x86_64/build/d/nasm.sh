#! /bin/bash

PRGNAME="nasm"

### NASM (Netwide Assembler)
# Портативный ассемблер и дизассемблер для микропроцессоров Intel 80x86 с
# традиционным синтаксисом Intel. NASM считается одним из самых популярных
# ассемблеров для Linux.

# Required:    no
# Recommended: no
# Optional:    python3-asciidoc
#              xmlto

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure \
    --prefix=/usr || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Netwide Assembler)
#
# NASM is the Netwide Assembler, a free portable assembler and disassembler for
# the Intel 80x86 microprocessor series, using primarily the traditional Intel
# instruction mnemonics and syntax. It can be used to write 16-bit, 32-bit
# (IA-32) and 64-bit (x86-64) programs. NASM is considered to be one of the
# most popular assemblers for Linux.
#
# Home page: https://www.${PRGNAME}.us/
# Download:  http://www.${PRGNAME}.us/pub/${PRGNAME}/releasebuilds/${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
