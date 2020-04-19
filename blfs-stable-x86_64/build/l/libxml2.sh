#! /bin/bash

PRGNAME="libxml2"

### libxml2 (XML parser library)
# Библиотеки и утилиты для анализа XML файлов

# http://www.linuxfromscratch.org/blfs/view/stable/general/libxml2.html

# Home page: http://xmlsoft.org/
# Download:  http://xmlsoft.org/sources/libxml2-2.9.10.tar.gz
# For tests: http://www.w3.org/XML/Test/xmlts20130923.tar.gz

# Required: no
# Optional: python2
#           python3
#           icu      (для тестов)
#           valgrind (для тестов)

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# отключим один тест, который препятствует полному их выполнению
sed -i 's/test.test/#&/' python/tests/tstLastError.py || exit 1

ICU="--without-icu"
command -v icuinfo &>/dev/null && ICU="--with-icu"

# включает поддержку Readline при запуске xmlcatalog или xmllint в консоли
#    --with-history
# собирать модуль libxml2 для Python3 вместо Python2
#    --with-python=/usr/bin/python3
# включить поддержку многопоточности
#    --with-threads
./configure          \
    --prefix=/usr    \
    --disable-static \
    --with-history   \
    --with-threads   \
    "${ICU}"         \
    --with-python=/usr/bin/python3 || exit 1

make || exit 1

# для тестов
tar xvf "${SOURCES}/xmlts20130923.tar.gz" || exit 1
#
# в тестах используется http://localhost/, поэтому на время тестов
# рекомендуется выключить сервер httpd
#    # /etc/init.d/httpd stop
#
# если установлен valgrind и мы хотим провести тесты на утечку памяти
# make check-valgrind
# иначе
# make check > check.log
#
# вывод общего результата тестов:
#    # grep -E '^Total|expected' check.log

make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (XML parser library)
#
# Libxml2 is the XML C parser library and toolkit. XML itself is a metalanguage
# to design markup languages -- i.e. a text language where structures are added
# to the content using extra "markup" information enclosed between angle
# brackets. HTML is the most well-known markup language. Though the library is
# written in C, a variety of language bindings make it available in other
# environments.
#
# Home page: http://xmlsoft.org/
# Download:  http://xmlsoft.org/sources/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
