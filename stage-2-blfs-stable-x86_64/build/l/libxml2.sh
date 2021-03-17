#! /bin/bash

PRGNAME="libxml2"

### libxml2 (XML parser library)
# Библиотеки и утилиты для анализа XML файлов

# Required: python3
# Optional: python2
#           icu      (для тестов)
#           valgrind (для тестов)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-security_fixes-1.patch" || exit 1

# исправим проблему сборки с Python3 v3.9.0 и выше
sed -i '/if Py/{s/Py/(Py/;s/)/))/}' python/{types.c,libxml.c} || exit 1

# отключим один тест, который препятствует полному их выполнению
sed -i 's/test.test/#&/' python/tests/tstLastError.py || exit 1

# исправим ошибку сборки с пакетом icu-68.2
sed -i 's/ TRUE/ true/' encoding.c

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
    "${ICU}"         \
    --with-python=/usr/bin/python3 || exit 1

make || exit 1

# распаковываем архив для тестов
# tar xvf "${SOURCES}/xmlts"[0-9]*.tar.?z* || exit 1
#
# в тестах используется http://localhost/, поэтому на время тестов
# рекомендуется отключить сервер httpd
#    # /etc/init.d/httpd stop
#
# если установлен valgrind и мы хотим провести тесты на утечку памяти
# make check-valgrind
# иначе
# make check > check.log
#
# вывод общего результата тестов:
#    # grep -E '^Total|expected' check.log

make install DESTDIR="${TMP_DIR}"

DOCS="${TMP_DIR}/usr/share/doc"
mv "${DOCS}/${PRGNAME}-python-${VERSION}" \
    "${DOCS}/${PRGNAME}-${VERSION}/${PRGNAME}-python"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

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
