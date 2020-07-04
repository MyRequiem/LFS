#! /bin/bash

PRGNAME="slang"

### S-Lang (S-Lang interpreter)
# Встраиваемый в программы интерпретируемый язык для обеспечения поддержки
# мощных расширений. Содержит библиотеки для разработки сложного, независимого
# от платформы программного кода, которые предоставляют возможности для
# управления экранами, обработки нажатия клавиш и низкоуровневого терминального
# ввода-вывода для интерактивных приложений.

# http://www.linuxfromscratch.org/blfs/view/stable/general/slang.html

# Home page: http://www.jedsoft.org/slang/
# Download:  http://www.jedsoft.org/releases/slang/slang-2.3.2.tar.bz2

# Required: no
# Optional: libpng
#           pcre
#           oniguruma (https://github.com/kkos/oniguruma)

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}${DOCS}/slsh"

# используем системную версию Readline вместо содержащейся в пакете slang
#    --with-readline=gnu
./configure             \
    --prefix=/usr       \
    --sysconfdir=/etc   \
    --with-readline=gnu || exit 1

# пакет не поддерживает сборку в несколько потоков
make -j1 || exit 1
# make check
make install_doc_dir="${DOCS}" SLSH_DOC_DIR="${DOCS}/slsh" install-all
make install_doc_dir="${DOCS}" SLSH_DOC_DIR="${DOCS}/slsh" install-all \
    DESTDIR="${TMP_DIR}"

chmod -v 755 "/usr/lib/libslang.so.${VERSION}" \
    /usr/lib/slang/v2/modules/*.so
chmod -v 755 "${TMP_DIR}/usr/lib/libslang.so.${VERSION}" \
    "${TMP_DIR}/usr/lib/slang/v2/modules"/*.so

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (S-Lang interpreter)
#
# S-Lang is an interpreted language that was designed from the start to be
# easily embedded into a program to provide it with a powerful extension
# language. S-Lang is also a programmer's library that permits a programmer to
# develop sophisticated platform-independent software. In addition to providing
# the S-Lang extension language, the library provides facilities for screen
# management, keymaps, and low-level terminal I/O required by interactive
# applications such as display/screen management, keyboard input and keymaps.
#
# Home page: http://www.jedsoft.org/${PRGNAME}/
# Download:  http://www.jedsoft.org/releases/${PRGNAME}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
