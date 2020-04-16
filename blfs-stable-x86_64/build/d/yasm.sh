#! /bin/bash

PRGNAME="yasm"

### yasm (complete rewrite of the NASM assembler)
# Ассемблер, являющийся попыткой полностью переписать ассемблер NASM. Yasm
# предлагает поддержку x86-64, которую NASM, возможно, не поддерживает должным
# образом или не поддерживает полностью. Например, проект Xvid может создать
# оптимизированный машинный код для x86-64 архитектуры, используя Yasm, но не
# может сделать так при использовании NASM. Кроме Intel-синтаксиса,
# применяемого в NASM, Yasm также поддерживает AT&T-синтаксис, распространённый
# в Unix. Yasm построен «модульно», что позволяет легко добавлять новые формы
# синтаксиса, препроцессоры и т. п.

# http://www.linuxfromscratch.org/blfs/view/stable/general/yasm.html

# Home page: http://www.tortall.net/projects/yasm/
# Download:  http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz

# Required: no
# Optional: python2
#           cython (https://cython.org/)

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исключаем сборку vsyasm и ytasm, которые используются только в Windows
sed -i 's#) ytasm.*#)#' Makefile.in

./configure \
    --prefix=/usr || exit 1

make || exit 1
# make check
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (complete rewrite of the NASM assembler)
#
# Yasm is a complete rewrite of the NASM assembler under the "new" BSD License
# (some portions are under other licenses, see COPYING for details). Yasm
# currently supports the x86 and AMD64 instruction sets, accepts NASM and GAS
# assembler syntaxes, outputs binary, ELF32, ELF64, 32 and 64-bit Mach-O,
# RDOFF2, COFF, Win32, and Win64 object formats, and generates source debugging
# information in STABS, DWARF 2, and CodeView 8 formats.
#
# Home page: http://www.tortall.net/projects/${PRGNAME}/
# Download:  http://www.tortall.net/projects/${PRGNAME}/releases/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
