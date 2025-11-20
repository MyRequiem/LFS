#! /bin/bash

PRGNAME="aspell"
DICT_EN_VER="2020.12.07-0"
DICT_RU_VER="0.99f7-1"

### Aspell (spell checker)
# Пакет содержит интерактивную программу проверки орфографии и библиотеки.
# Aspell может быть использован как библиотека или как самостоятельная
# программа проверки орфографии.

# Required:    which (для словарей)
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим проблему сборки с gcc-15
sed -e 's/; i.*size)/, e = end(); i != e; ++i, ++size_)/' \
    -i modules/speller/default/vector_hash-t.hpp || exit 1

./configure \
    --prefix=/usr || exit 1

make || exit 1
# пакет не содержит набора тестов

# сразу устанавливаем в систему, т.к. является зависимостью для словарей
# (см. далее)
make install
make install DESTDIR="${TMP_DIR}"

# ссылка в /usr/lib/
# требуется при конфигурации других приложений, например enchant
#    aspell -> aspell-0.60/
ln -svfn aspell-0.60 "${TMP_DIR}/usr/lib/aspell"

# Spell и Ispell не устанавливаем, поэтому скопируем скрипт-обертку ispell и
# spell в /usr/bin
install -v -m 755 scripts/{,i}spell  "${TMP_DIR}/usr/bin/"

###
# словари
###
# EN
tar xvf "${SOURCES}/${PRGNAME}6-en-${DICT_EN_VER}.tar.bz2" || exit 1
cd "${PRGNAME}6-en-${DICT_EN_VER}" || exit 1

./configure || exit 1
make        || exit 1
make install DESTDIR="${TMP_DIR}"
cd .. || exit 1

# RU
tar xvf "${SOURCES}/${PRGNAME}6-ru-${DICT_RU_VER}.tar.bz2" || exit 1
cd "${PRGNAME}6-ru-${DICT_RU_VER}" || exit 1

./configure || exit 1
make        || exit 1
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (spell checker)
#
# GNU Aspell is a spell checker designed to eventually replace Ispell. It can
# either be used as a library or as an independent spell checker.
#
# Home page: http://${PRGNAME}.net/
# Download:  https://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#            https://ftp.gnu.org/gnu/${PRGNAME}/dict/en/${PRGNAME}6-en-${DICT_EN_VER}.tar.bz2
#            https://ftp.gnu.org/gnu/${PRGNAME}/dict/ru/${PRGNAME}6-ru-${DICT_RU_VER}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
