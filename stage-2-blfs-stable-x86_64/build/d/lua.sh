#! /bin/bash

PRGNAME="lua"

### Lua (a powerful, fast, lightweight, embeddable scripting language)
# Мощный и легкий язык программирования, предназначенный для расширения
# приложений. Также часто используется в качестве универсального и автономного
# языка. Lua реализован в виде небольшой библиотеки функций C, написанных на
# ANSI С, и компилируется на всех известных платформах. Цели реализации это
# простота, эффективность, портативность, встраиваимость.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# некоторые пакеты проверяют файл pkg-config для Lua, поэтому создадим его
MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > lua.pc
V=${MAJ_VERSION}
R=${VERSION}

prefix=/usr
INSTALL_BIN=\${prefix}/bin
INSTALL_INC=\${prefix}/include
INSTALL_LIB=\${prefix}/lib
INSTALL_MAN=\${prefix}/share/man/man1
INSTALL_LMOD=\${prefix}/share/lua/\${V}
INSTALL_CMOD=\${prefix}/lib/lua/\${V}
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: Lua
Description: An Extensible Extension Language
Version: \${R}
Requires:
Libs: -L\${libdir} -llua -lm -ldl
Cflags: -I\${includedir}
EOF

patch -Np1 --verbose -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-shared_library-1.patch" || exit 1

make linux

# тест запустит интерпретатор и выведет версию lua
echo -e "\n--- Test Lua version ---"
make test
echo -e "------------------------"
echo -n "Press any key... "
read -r JUNK
echo "${JUNK}" > /dev/null

make                                                                 \
    INSTALL_TOP="${TMP_DIR}/usr"                                     \
    INSTALL_DATA="cp -d"                                             \
    INSTALL_MAN="${TMP_DIR}/usr/share/man/man1"                      \
    TO_LIB="liblua.so liblua.so.${MAJ_VERSION} liblua.so.${VERSION}" \
    install || exit 1

install -v -m644 -D lua.pc "${TMP_DIR}/usr/lib/pkgconfig/lua.pc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (fast, lightweight, embeddable scripting language)
#
# Lua is a powerful light-weight programming language designed for extending
# applications. It is also frequently used as a general-purpose, stand-alone
# language. Lua is implemented as a small library of C functions, written in
# ANSI C, and compiles unmodified in all known platforms. The implementation
# goals are simplicity, efficiency, portability, and low embedding cost. The
# result is a fast language engine with small footprint, making it ideal in
# embedded systems too.
#
# Home page: http://www.lua.org/
# Download:  https://www.lua.org/ftp/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
