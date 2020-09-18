#! /bin/bash

PRGNAME="lua53"
ARCH_NAME="lua"
VERSION="5.3.5"
TEST_VERSION="5.3.4"

### Lua v5.3.x (a powerful, fast, lightweight, embeddable scripting language)
# Мощный и легкий язык программирования, предназначенный для расширения
# приложений. Также часто используется в качестве универсального и автономного
# языка. Lua реализован в виде небольшой библиотеки функций C, написанных на
# ANSI С, и компилируется на всех известных платформах. Цели реализации это
# простота, эффективность, портативность, встраиваимость.

# http://www.linuxfromscratch.org/blfs/view/stable/general/lua.html

# Home page: http://www.lua.org/
# Download:  http://www.lua.org/ftp/lua-5.3.5.tar.gz
# Patch:     http://www.linuxfromscratch.org/patches/blfs/9.1/lua-5.3.5-shared_library-1.patch
# Tests:     http://www.lua.org/tests/lua-5.3.4-tests.tar.gz

# Required: no
# Optional: no

ROOT="/root"
source "${ROOT}/check_environment.sh"                                 || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" "${VERSION}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}${DOCS}"

# некоторые пакеты проверяют файл pkg-config для Lua, поэтому создадим его:
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
    "${SOURCES}/${ARCH_NAME}-${VERSION}-shared_library-1.patch" || exit 1

# изменим путь поиска Lua в соответствии с путем установки
# /usr/local/bin/lua -> /usr/bin/lua
sed -i '/#define LUA_ROOT/s:/usr/local/:/usr/:' src/luaconf.h || exit 1

# включаем совместимость Lua с предыдущими версиями 5.1 и 5.2
make MYCFLAGS="-DLUA_COMPAT_5_2 -DLUA_COMPAT_5_1" linux

# следующий тест запустит интерпретатор командой 'src/lua -v' и выведет версию
# lua
echo -e "\n--- Test Lua version ---"
make test
echo -e "------------------------\n"

make                                \
    INSTALL_TOP=/usr                \
    INSTALL_DATA="cp -d"            \
    INSTALL_MAN=/usr/share/man/man1 \
    TO_LIB="liblua.so liblua.so.5.3 liblua.so.5.3.4" install || exit 1

make                                            \
    INSTALL_TOP="${TMP_DIR}/usr"                \
    INSTALL_DATA="cp -d"                        \
    INSTALL_MAN="${TMP_DIR}/usr/share/man/man1" \
    TO_LIB="liblua.so liblua.so.5.3 liblua.so.5.3.4" install || exit 1

mkdir -pv "${DOCS}"
cp -v doc/*.{html,css,gif,png} "${DOCS}"
cp -v doc/*.{html,css,gif,png} "${TMP_DIR}${DOCS}"

install -v -m644 -D lua.pc /usr/lib/pkgconfig/lua.pc
install -v -m644 -D lua.pc "${TMP_DIR}/usr/lib/pkgconfig/lua.pc"

# распакуем архив с тестами
tar xvf "${SOURCES}/${ARCH_NAME}-${TEST_VERSION}-tests"*.tar.?z* || exit 1
cd ${ARCH_NAME}-${TEST_VERSION}-tests || exit 1

# запустим тесты
# если нет ошибок будет выведена строка: final OK
lua -e "_U=true" all.lua

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
# Download:  http://www.lua.org/ftp/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
