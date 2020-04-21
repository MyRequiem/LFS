#! /bin/bash

PRGNAME="libidn"

### libidn (GNU Internationalized Domain Name library)
# Пакет, разработанный для интернационализированной обработки строк на основе
# спецификации Stringprep, Punycode и IDNA, определенные в Интернете.
# Применяется для конвертации данных из системного представления в UTF-8,
# преобразуя Unicode строки в строки ASCII, позволяющие приложениям
# использовать определенное доменное имя в ASCII формате.

# http://www.linuxfromscratch.org/blfs/view/stable/general/libidn.html

# Home page: http://www.gnu.org/software/libidn/
# Download:  https://ftp.gnu.org/gnu/libidn/libidn-1.35.tar.gz

# Required: no
# Optional: pth
#           emacs
#           gtk-doc (для сборки API документации)
#           openjdk
#           valgrind
#           mono (https://www.mono-project.com/)

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}${DOCS}"

THREADS="posix"
GTK_DOC="--disable-gtk-doc"
OPENJDK="--disable-java"
VALGRIND="--disable-valgrind-tests"
MONO="--disable-csharp"

command -v pth-config   &>/dev/null && THREADS="pth"
command -v gtkdoc-check &>/dev/null && GTK_DOC="--enable-gtk-doc"
command -v java         &>/dev/null && OPENJDK="--enable-java"
command -v valgrind     &>/dev/null && VALGRIND="--enable-valgrind-tests"
command -v mono         &>/dev/null && MONO="--enable-csharp"

./configure                       \
    --prefix=/usr                 \
    --enable-threads="${THREADS}" \
    "${GTK_DOC}"                  \
    "${OPENJDK}"                  \
    "${VALGRIND}"                 \
    "${MONO}"                     \
    --disable-static || exit 1

make || exit 1
# make check
make install
make install DESTDIR="${TMP_DIR}"

# документация
mkdir -pv "${DOCS}"
find doc -name "Makefile*" -delete
rm -rfv doc/{gdoc,idn.1,stamp-vti,man,texi}
cp -Rv doc/* "${DOCS}"
cp -Rv doc/* "${TMP_DIR}${DOCS}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GNU Internationalized Domain Name library)
#
# libidn is a package designed for internationalized string handling based on
# the Stringprep, Punycode and IDNA specifications defined by the Internet
# Engineering Task Force (IETF) Internationalized Domain Names (IDN) working
# group, used for internationalized domain names. This is useful for converting
# data from the systems native representation into UTF-8, transforming Unicode
# strings into ASCII strings, allowing applications to use certain ASCII name
# labels (beginning with a special prefix) to represent non-ASCII name labels,
# and converting entire domain names to and from the ASCII Compatible Encoding
# (ACE) form.
#
# Home page: http://www.gnu.org/software/${PRGNAME}/
# Download:  https://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
