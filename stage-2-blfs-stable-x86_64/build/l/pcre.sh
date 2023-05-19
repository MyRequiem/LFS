#! /bin/bash

PRGNAME="pcre"

### PCRE (Perl-compatible regular expression library)
# Совместимые с Perl библиотеки регулярных выражений, которые используются для
# реализации сопоставления с шаблоном регулярного выражения, используя тот же
# синтаксис и семантику что и в Perl 5

# Required:    no
# Recommended: no
# Optional:    valgrind

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

VALGRIND="--disable-valgrind"
# command -v valgrind &>/dev/null && VALGRIND="--enable-valgrind"

# включает поддержку Unicode и код для обработки UTF-8/16/32 символов
#    --enable-unicode-properties
# включает поддержку 16-битных символов
#    --enable-pcre16
# включает поддержку 32-битных символов
#    --enable-pcre32
# добавляет поддержку pcregrep для чтения сжатых файлов .gz
#    --enable-pcregrep-libz
# добавляет поддержку pcregrep для чтения сжатых файлов .bz2
#    --enable-pcregrep-libbz2
# добавляет функции редактирования строк и истории в программу pcretest
#    --enable-pcretest-libreadline
# включает компиляцию "Just-in-time", что может значительно ускорить
# сопоставление с паттерном
#    --enable-jit
./configure                       \
    --prefix=/usr                 \
    --enable-unicode-properties   \
    --enable-pcre16               \
    --enable-pcre32               \
    --enable-pcregrep-libz        \
    --enable-pcregrep-libbz2      \
    --enable-pcretest-libreadline \
    --disable-static              \
    --enable-jit                  \
    "${VALGRIND}"                 \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Perl-compatible regular expression library)
#
# The PCRE library is a set of functions that implement regular expression
# pattern matching using the same syntax and semantics as Perl 5, with just a
# few differences (documented in the man page)
#
# Home page: https://www.${PRGNAME}.org/
# Download:  https://sourceforge.net/projects/${PRGNAME}/files/${PRGNAME}/${VERSION}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
