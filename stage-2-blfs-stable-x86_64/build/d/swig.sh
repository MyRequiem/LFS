#! /bin/bash

PRGNAME="swig"

### SWIG (Simplified Wrapper and Interface Generator)
# Инструмент для связывания программ и библиотек, написанных на C и C++ с
# интерпретируемыми (Tcl, Perl, Python, Ruby, PHP) или компилируемыми (Java,
# C#, Scheme, OCaml) языками. Основная цель: обеспечение возможности вызова
# функций, написанных на одних языках, из кода на других языках. Программист
# создаёт файл с описанием экспортируемых функций, SWIG генерирует исходный код
# для склеивания C/C++ и нужного языка, и затем создаёт исполняемый файл.

# Required:    pcre2
# Recommended: no
# Optional:    boost (для тестов)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# отключаем сборку тестов и примеров для javascript
#    --without-javascript
# отключает принудительное соответствие компилятора ansi, что вызывает ошибки в
# заголовках Lua >= 5.3
#    --without-maximum-compile-warnings
./configure              \
    --prefix=/usr        \
    --without-javascript \
    --without-maximum-compile-warnings || exit 1

make || exit 1

# тесты
# PY3=1 make -k check TCL_INCLUDE=.

make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Simplified Wrapper and Interface Generator)
#
# SWIG is an interface compiler that connects programs written in C and C++
# with scripting languages such as Perl, Python, Ruby, and Tcl. It works by
# taking the declarations found in C/C++ header files and using them to
# generate the wrapper code that scripting languages need to access the
# underlying C/C++ code. In addition, SWIG provides a variety of customization
# features that let you tailor the wrapping process to suit your application.
#
# Home page: http://www.${PRGNAME}.org/
# Download:  https://downloads.sourceforge.net/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
