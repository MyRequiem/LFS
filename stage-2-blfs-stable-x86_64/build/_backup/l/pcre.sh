#! /bin/bash

PRGNAME="pcre"

### PCRE (Perl-compatible regular expression library)
# Совместимые с Perl библиотеки регулярных выражений, которые используются для
# реализации сопоставления с шаблоном регулярного выражения, используя тот же
# синтаксис и семантику что и в Perl 5

# http://www.linuxfromscratch.org/blfs/view/stable/general/pcre.html

# Home page: https://www.pcre.org/
# Download:  https://ftp.pcre.org/pub/pcre/pcre-8.44.tar.bz2

# Required: no
# Optional: valgrind

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/lib"

VALGRIND="--disable-valgrind"
command -v valgrind &>/dev/null && VALGRIND="--enable-valgrind"

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
make install
make install DESTDIR="${TMP_DIR}"

# переместим библиотеку PCRE в корень файловой системы /lib, чтобы она была
# доступна в случае переустановки grep с поддержкой PCRE
mv -v /usr/lib/libpcre.so.* /lib
mv -v "${TMP_DIR}/usr/lib/libpcre.so."* "${TMP_DIR}/lib"

ln -sfv "../../lib/$(readlink /usr/lib/libpcre.so)" /usr/lib/libpcre.so
(
    cd "${TMP_DIR}/usr/lib" || exit 1
    ln -sfv "../../lib/$(readlink libpcre.so)" libpcre.so
)

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Perl-compatible regular expression library)
#
# The PCRE library is a set of functions that implement regular expression
# pattern matching using the same syntax and semantics as Perl 5, with just a
# few differences (documented in the man page)
#
# Home page: https://www.pcre.org/
# Download:  https://ftp.pcre.org/pub/${PRGNAME}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
