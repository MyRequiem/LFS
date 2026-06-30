#! /bin/bash

PRGNAME="swig"

### SWIG (Simplified Wrapper and Interface Generator)
# Инструмент для связывания кода, написанного на языках C или C++, с другими
# языками вроде Tcl, Python, Perl, PHP, Ruby, Java, C# и т.д. Позволяет
# разработчикам использовать готовые быстрые модули в своих проектах.

# Required:    no
# Recommended: no
# Optional:    boost    (для тестов)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure \
    --prefix=/usr || exit 1

make || exit 1
# тесты
# make JSCXX=g++ TCL_INCLUDE= -k check
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
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
# Home page: https://www.${PRGNAME}.org/
# Download:  https://downloads.sourceforge.net/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
