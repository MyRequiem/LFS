#! /bin/bash

PRGNAME="libassuan"

### libassuan (Interprocess Communication Library for GPG)
# Небольшая библиотека, реализующая так называемый протокол Assuan. Этот
# протокол используется для IPC между большинством компонентов GnuPG.
# Представлена как серверная, так и клиентская часть.

# Required:    libgpg-error
# Recommended: no
# Optional:    texlive или install-tl-unx (для создания pdf и ps документации)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}${DOCS}"

./configure \
    --prefix=/usr || exit 1

make || exit 1

# собираем документацию в формате html и plaintext
make -C doc html || exit 1
makeinfo --html --no-split -o doc/assuan_nochunks.html doc/assuan.texi
makeinfo --plaintext       -o doc/assuan.txt           doc/assuan.texi

# если в системе установлен texlive или install-tl-unx, можно создать
# документацию в форматах pdf и ps
PDF_PS_DOC=""
# command -v texdoc &>/dev/null && PDF_PS_DOC="true"
[ -n "${PDF_PS_DOC}" ] && make -C doc pdf ps

# make check

make install DESTDIR="${TMP_DIR}"

install -v -m644 doc/assuan_nochunks.html "${TMP_DIR}${DOCS}"
install -v -m644 doc/assuan.txt           "${TMP_DIR}${DOCS}"

# если мы собирали документацию в pdf и ps форматах
if [ -n "${PDF_PS_DOC}" ]; then
    install -v -m644  doc/assuan.{pdf,ps,dvi} "${TMP_DIR}${DOCS}"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Interprocess Communication Library for GPG)
#
# This is a small library implementing the so-called Assuan protocol. This
# protocol is used for IPC between most newer GnuPG components. Both, server
# and client side functions are provided.
#
# Home page: https://gnupg.org/software/${PRGNAME}/index.html
# Download:  https://www.gnupg.org/ftp/gcrypt/${PRGNAME}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
