#! /bin/bash

PRGNAME="aspell"

### Aspell
# Пакет содержит интерактивную программу проверки орфографии и библиотеки.
# Aspell может быть использован как библиотека или как самостоятельная
# программа проверки орфографии.

# http://www.linuxfromscratch.org/blfs/view/9.0/general/aspell.html

# Home page: http://aspell.net/
# Download:  https://ftp.gnu.org/gnu/aspell/aspell-0.60.7.tar.gz

# Required: which
# Optional: no

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/usr"/{bin,"share/doc/${PRGNAME}-${VERSION}"}

# исправим проблему сборки с gcc7
sed -i '/ top.do_check ==/s/top.do_check/*&/' modules/filter/tex.cpp

./configure \
    --prefix=/usr || exit 1

make || exit 1
# пакет не содержит набора тестов
make install
make install DESTDIR="${TMP_DIR}"

# ссылка aspell в /usr/lib/ на директорию aspell-0.60
ln -svfn aspell-0.60 /usr/lib/aspell
ln -svfn aspell-0.60 "${TMP_DIR}/usr/lib/aspell"

DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
# создаем директории в /usr/share/doc/${PRGNAME}-${VERSION}
#    aspell.html
#    aspell-dev.html в
install -v -m755 -d "${DOCS}"/aspell{,-dev}.html
install -v -m755 -d "${TMP_DIR}${DOCS}"/aspell{,-dev}.html

install -v -m644 manual/aspell.html/* "${DOCS}/aspell.html"
install -v -m644 manual/aspell.html/* "${TMP_DIR}${DOCS}/aspell.html"

install -v -m644 manual/aspell-dev.html/* "${DOCS}/aspell-dev.html"
install -v -m644 manual/aspell-dev.html/* "${TMP_DIR}${DOCS}/aspell-dev.html"

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
