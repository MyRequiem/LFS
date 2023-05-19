#! /bin/bash

PRGNAME="pcre2"

### PCRE2 (Perl-compatible regular expression library)
# Совместимые с Perl библиотеки регулярных выражений нового поколения (в
# отличие от pcre), которые используются для реализации сопоставления с
# шаблоном регулярного выражения, используя тот же синтаксис и семантику что и
# в Perl 5

# Required:    no
# Recommended: no
# Optional:    valgrind
#              libedit    (https://www.cs.utah.edu/~bigler/code/libedit.html)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

VALGRIND="--disable-valgrind"
LIBEDIT="--disable-pcre2test-libedit"

# command -v valgrind &>/dev/null && VALGRIND="--enable-valgrind"
[ -x /usr/lib/libedit.so ] && LIBEDIT="--enable-pcre2test-libedit"

# включает поддержку Unicode и функции для обработки UTF-8/16/32 символов
#    --enable-unicode
# "Just-in-time" компиляция, что может значительно ускорить сопоставление
# с образцом
#    --enable-jit
# включает поддержку 16-битных символов
#    --enable-pcre2-16
# включает поддержку 32-битных символов
#    --enable-pcre2-32
# добавляет поддержку pcregrep для чтения сжатых файлов .gz
#    --enable-pcre2grep-libz
# добавляет поддержку pcregrep для чтения сжатых файлов .bz2
#    --enable-pcre2grep-libbz2
# добавляет функции редактирования строк и истории в программу pcre2test
#    --enable-pcre2test-libreadline
./configure                        \
    --prefix=/usr                  \
    --enable-unicode               \
    --enable-jit                   \
    --enable-pcre2-16              \
    --enable-pcre2-32              \
    --enable-pcre2grep-libz        \
    --enable-pcre2grep-libbz2      \
    --enable-pcre2test-libreadline \
    "${LIBEDIT}"                   \
    "${VALGRIND}"                  \
    --disable-static               \
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
# The PCRE2 package contains a new generation of the Perl Compatible Regular
# Expression libraries. This library is a set of functions that implement
# regular expression pattern matching using the same syntax and semantics as
# Perl 5, with just a few differences (documented in the man page)
#
# Home page: https://www.pcre.org/
# Download:  https://github.com/PCRE2Project/${PRGNAME}/releases/download/${PRGNAME}-${VERSION}/${PRGNAME}-${VERSION}.tar.bz2

#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
