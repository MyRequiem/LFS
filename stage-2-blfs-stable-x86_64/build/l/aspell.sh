#! /bin/bash

PRGNAME="aspell"

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
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}${DOCS}/html"

./configure \
    --prefix=/usr || exit 1

make || exit 1
# пакет не содержит набора тестов
make install DESTDIR="${TMP_DIR}"

# ссылка в /usr/lib/ aspell -> aspell-0.60 (требуется при конфигурации других
# приложений, например enchant)
ln -svfn aspell-0.60 "${TMP_DIR}/usr/lib/aspell"

# документация
cp -a COPYING README TODO             "${TMP_DIR}${DOCS}"
install -v -m644 manual/aspell.html/* "${TMP_DIR}${DOCS}/html"

# Spell и Ispell не устанавливаем, поэтому скопируем скрипт-обертку ispell и
# spell в /usr/bin
install -v -m 755 scripts/{,i}spell  "${TMP_DIR}/usr/bin/"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (spell checker)
#
# GNU Aspell is a spell checker designed to eventually replace Ispell. It can
# either be used as a library or as an independent spell checker.
#
# Home page: http://aspell.net/
# Download:  https://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
