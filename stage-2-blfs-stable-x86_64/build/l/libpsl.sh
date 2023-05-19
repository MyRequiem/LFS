#! /bin/bash

PRGNAME="libpsl"

### libpsl (A Public Suffix List)
# Public Suffix List (PSL) - библиотека суффиксов доменов верхнего уровня (Top
# Level Domains - TLD). TLD включает глобальные домены верхнего уровня (gTLD),
# такие как .com и .net, Country Top Level Домены (ccTLD), такие как .de и .cn
# и домены верхнего уровня бренда (Brand Top Level Domains), такие как .apple и
# .google. Брендовые TLD позволяют пользователям регистрировать свой
# собственный домен верхнего уровня, который существует на том же уровне что и
# gTLDs

# Required:    libidn2
# Recommended: no
# Optional:    gtk-doc  (для сборки документации)
#              valgrind (для тестов)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# принудительно используем Python3
sed -i 's/env python/&3/' src/psl-make-dafsa || exit 1

GTK_DOC="--disable-gtk-doc"
# command -v gtkdoc-check &>/dev/null && GTK_DOC="--enable-gtk-doc"

./configure          \
    PYTHON=python3   \
    --prefix=/usr    \
    "${GTK_DOC}"     \
    --disable-static \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (A Public Suffix List)
#
# A Public Suffix List is a collection of Top Level Domains (TLDs) suffixes.
# TLDs include Global Top Level Domains (gTLDs) like .com and .net; Country Top
# Level Domains (ccTLDs) like .de and .cn; and Brand Top Level Domains like
# .apple and .google. Brand TLDs allows users to register their own top level
# domain that exist at the same level as ICANN's gTLDs. Brand TLDs are
# sometimes referred to as Vanity Domains.
#
# Home page: https://github.com/rockdaboot/${PRGNAME}
# Download:  https://github.com/rockdaboot/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
