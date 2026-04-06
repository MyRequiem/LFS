#! /bin/bash

PRGNAME="luajit"

### LuaJIT (Just-In-Time compiler for Lua)
# Высокопроизводительный компилятор для языка Lua, что делает выполнение
# скриптов почти таким же быстрым, как у программ на C при использовании
# минимального объема памяти.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# параметр amalg обеспечивает объединенную сборку, т.е. ядро LuaJIT
# компилируется как один огромный C-файл, что позволяет GCC генерировать более
# быстрый и короткий код
make PREFIX=/usr amalg
# пакет не имеет набора тестов
make PREFIX=/usr install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

# удалим статическую библиотеку
rm -v "${TMP_DIR}/usr/lib/libluajit-5.1.a"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Just-In-Time compiler for Lua)
#
# The luajit package contains a Just-In-Time (JIT) compiler for Lua programming
# language. It is often used; as scripting middleware, and it is high
# performance while also having a low memory footprint.
#
# Home page: https://${PRGNAME}.org
# Download:  https://anduin.linuxfromscratch.org/BLFS/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
