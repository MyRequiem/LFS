#! /bin/bash

PRGNAME="libffi"

### Libffi (A Portable Foreign Function Interface Library)
# Библиотека, предоставляющая переносимый программный интерфейс высокого уровня
# для различных соглашений о вызовах. Это позволяет программисту вызывать любую
# функцию определенную описанием интерфейса вызова во время выполнения

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# GCC будет проводить оптимизацию сборки для текущей системы
#    --with-gcc-arch=native
./configure          \
    --prefix=/usr    \
    --disable-static \
    --with-gcc-arch=native || exit 1

make || make -j1 || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

rm -f "${TMP_DIR}/usr/share/info/dir"

/bin/cp -vR "${TMP_DIR}"/* /

# система документации Info использует простые текстовые файлы в
# /usr/share/info/, а список этих файлов хранится в файле /usr/share/info/dir
# который мы обновим
cd /usr/share/info || exit 1
rm -fv dir
for FILE in *; do
    install-info "${FILE}" dir 2>/dev/null
done

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (A Portable Foreign Function Interface Library)
#
# FFI stands for Foreign Function Interface. A foreign function interface is
# the popular name for the interface that allows code written in one language
# to call code written in another language. This allows a programmer to call
# any function specified by a call interface description at run time. The
# libffi library really only provides the lowest, machine dependent layer of a
# fully featured foreign function interface.
#
# Home page: https://sourceware.org/${PRGNAME}/
# Download:  ftp://sourceware.org/pub/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
