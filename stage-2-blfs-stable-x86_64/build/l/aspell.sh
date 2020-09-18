#! /bin/bash

PRGNAME="aspell"

### Aspell (spell checker)
# Пакет содержит интерактивную программу проверки орфографии и библиотеки.
# Aspell может быть использован как библиотека или как самостоятельная
# программа проверки орфографии.

# http://www.linuxfromscratch.org/blfs/view/stable/general/aspell.html

# Home page: http://aspell.net/
# Download:  https://ftp.gnu.org/gnu/aspell/aspell-0.60.8.tar.gz

# Required: which (для словарей)
# Optional: no

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure \
    --prefix=/usr || exit 1

make || exit 1
# пакет не содержит набора тестов
make install
make install DESTDIR="${TMP_DIR}"

# ссылка в /usr/lib/ aspell -> aspell-0.60 (используется при конфигурации
# других приложений, например enchant)
ln -svfn aspell-0.60 /usr/lib/aspell
ln -svfn aspell-0.60 "${TMP_DIR}/usr/lib/aspell"

DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
install -v -m755 -d "${DOCS}"/aspell{,-dev}.html
install -v -m755 -d "${TMP_DIR}${DOCS}"/aspell{,-dev}.html

install -v -m644 manual/aspell.html/* "${DOCS}/aspell.html"
install -v -m644 manual/aspell.html/* "${TMP_DIR}${DOCS}/aspell.html"

install -v -m644 manual/aspell-dev.html/* "${DOCS}/aspell-dev.html"
install -v -m644 manual/aspell-dev.html/* "${TMP_DIR}${DOCS}/aspell-dev.html"

# ispell устанавливать не будем, поэтому скопируем скрипт-обертку ispell и
# spell в /usr/bin
install -v -m 755 scripts/ispell /usr/bin/
install -v -m 755 scripts/ispell "${TMP_DIR}/usr/bin/"

install -v -m 755 scripts/spell /usr/bin/
install -v -m 755 scripts/spell "${TMP_DIR}/usr/bin/"

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
