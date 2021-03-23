#! /bin/bash

PRGNAME="libgcrypt"

### libgcrypt (General purpose crypto library)
# Криптобиблиотека общего назначения, основанная на коде, используемом в GnuPG.
# Библиотека предоставляет интерфейс высокого уровня для криптографии с
# использованием расширяемого и гибкого API

# Required:    libgpg-error
# Recommended: no
# Optional:    pth
#              texlive или install-tl-unx (для создания pdf и ps документации)

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
make -C doc html
# makeinfo --html --no-split -o doc/gcrypt_nochunks.html doc/gcrypt.texi
makeinfo --plaintext -o doc/gcrypt.txt doc/gcrypt.texi

# если в системе установлен texlive или install-tl-unx, можно создать
# документацию в форматах pdf и ps
PDF_PS_DOC=""
# command -v texdoc &>/dev/null && PDF_PS_DOC="true"
[ -n "${PDF_PS_DOC}" ] && make -C doc pdf ps

# make check

make install DESTDIR="${TMP_DIR}"

# установим документацию
install -v -m644 README doc/README.apichanges "${TMP_DIR}${DOCS}"
install -v -m644 doc/gcrypt.txt               "${TMP_DIR}${DOCS}"
# install -v -m644 doc/gcrypt_nochunks.html "${TMP_DIR}${DOCS}"
# install -v -m644 doc/gcrypt.html/*        "${TMP_DIR}${DOCS}/html"

# если мы собирали документацию в pdf и ps форматах
if [ -n "${PDF_PS_DOC}" ]; then
    install -v -m644 doc/gcrypt.{pdf,ps,dvi} "${TMP_DIR}${DOCS}"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (General purpose crypto library)
#
# The libgcrypt package contains a general purpose crypto library based on the
# code used in GnuPG. The library provides a high level interface to
# cryptographic building blocks using an extendable and flexible API.
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
