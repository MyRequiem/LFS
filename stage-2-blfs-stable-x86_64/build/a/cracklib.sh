#! /bin/bash

PRGNAME="cracklib"

### CrackLib (password checking library)
# Библиотека для проверки стойкости/надежности паролей, предотвращающая
# использование слишком простых и легко предсказуемых комбинаций.

# Required:    no
# Recommended: no
# Optional:    no

### IMPORTANT
# Если хотим обеспечить поддержку надежных паролей в системе, после
# установки/переустановки/обновления пакета CrackLib необходимо пересобрать
# пакет 'shadow'.

### NOTE:
# Далее мы будем устанавливать пакет 'linux-pam', после которого 'shadow' нужно
# будет обязательно пересобрать.

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
LIB_CRACKLIB="/usr/lib/cracklib"
DICT="/usr/share/dict"
mkdir -pv "${TMP_DIR}"{"${LIB_CRACKLIB}","${DICT}"}

./configure          \
    --prefix=/usr    \
    --disable-static \
    --with-default-dict="/usr/lib/${PRGNAME}/pw_dict" || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

# Создадим список нежелательных слов для выбора в качестве паролей
# cracklib-words-2.10.3.xz
# Можно скачать и установить сколько угодно таких списков:
#    https://www.skullsecurity.org/wiki/Passwords
xzcat "${SOURCES}/${PRGNAME}-words-${VERSION}.xz" > \
    "${TMP_DIR}${DICT}/cracklib-words" || exit 1

# Ссылка /usr/share/dict/words -> cracklib-words
ln -v -sf cracklib-words "${TMP_DIR}${DICT}/words"

# Создадим свой список слов cracklib-extra-words, например, с одним словом -
# имя хоста.
hostname >> "${TMP_DIR}${DICT}/cracklib-extra-words"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# Создадим словарь /usr/lib/cracklib/pw_dict.{hwm,pwd,pwi}
create-cracklib-dict               \
    /usr/share/dict/cracklib-words \
    /usr/share/dict/cracklib-extra-words

cp "${LIB_CRACKLIB}"/* "${TMP_DIR}${LIB_CRACKLIB}"/

# Тест python-модуля (только после установки пакета):
#    $ python3 -c 'import cracklib; cracklib.test()'
#    cracklib is installed in: /usr/lib/python3.14/site-packages
#    cracklib version: 2.8.19
#    3.14.7 (main, Sep  5 2026, 07:54:40) [GCC 16.2.0]
#    ...........
#    ----------------------------------------------------------------------
#    Ran 11 tests in 0.007s
#
#    OK

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (password checking library)
#
# The CrackLib package contains a library used to enforce strong passwords by
# comparing user selected passwords to words in chosen word lists
#
# Home page: https://github.com/${PRGNAME}/${PRGNAME}/
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
