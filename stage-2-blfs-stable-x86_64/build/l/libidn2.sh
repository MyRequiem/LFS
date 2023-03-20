#! /bin/bash

PRGNAME="libidn2"

### libidn2 (GNU Internationalized Domain Name library version 2)
# Пакет, разработанный для интернационализированной обработки строк на основе
# спецификации Stringprep, Punycode и IDNA, определенные в Интернете.
# Применяется для конвертации данных из системного представления в UTF-8,
# преобразуя Unicode строки в строки ASCII, позволяющие приложениям
# использовать определенное доменное имя в ASCII формате.

# Required:    libunistring
# Recommended: no
# Optional:    git
#              gtk-doc (для создания API документации)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

GTK_DOC="--disable-gtk-doc"
# command -v gtkdoc-check &>/dev/null && GTK_DOC="--enable-gtk-doc"

./configure       \
    --prefix=/usr \
    "${GTK_DOC}"  \
    --disable-static || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

[[ "x${GTK_DOC}" == "x--disable-gtk-doc" ]] && \
    rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GNU Internationalized Domain Name library version 2)
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
# Home page: https://www.gnu.org/software/libidn/
# Download:  https://ftp.gnu.org/gnu/libidn/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
