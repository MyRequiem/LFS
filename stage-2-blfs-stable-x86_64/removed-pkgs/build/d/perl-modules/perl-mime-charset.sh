#! /bin/bash

PRGNAME="perl-mime-charset"
ARCH_NAME="MIME-Charset"

### MIME::Charset (charset Information for MIME)
# MIME::Charset Perl модуль

# Required:    no
# Recommended: --- требуются для сборки пакета biber ---
#              perl-encode-eucjpascii
#              perl-encode-hanextra
#              perl-encode-jis2k
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# во время установки Perl спрашивает, хотите ли вы установить отсутствующий
# модуль Encode::JISX0213 для устаревших японских кодировок из базы CPAN?
#    [Additional mappings for JIS X 0213]
#    - Encode::JISX0213   ...missing. (would need 0.03)
#    ==> Auto-install the 1 optional module(s) from CPAN? [n]
# затем спрашивает нужно ли установить модуль для перевода документации на
# японский язык
#    [Support for POD2 - translations of Perl documentation]
#    - POD2::Base         ...missing. (would need 0.041)
#    ==> Auto-install the 1 optional module(s) from CPAN? [n]
# ...
# на все вопросы  отвечаем 'no' с помощью инструкции "yes '' | ..."
# ...
yes '' | perl Makefile.PL || exit 1
make                      || exit 1
# make test
make install DESTDIR="${TMP_DIR}"

# удалим perllocal.pod и другие служебные файлы, которые не нужно устанавливать
find "${TMP_DIR}" \
    \( -name perllocal.pod -o -name ".packlist" -o -name "*.bs" \) \
    -exec rm {} \;

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (charset Information for MIME)
#
# MIME::Charset provides information about character sets used for MIME
# messages o nthe internet, such as their encodings
#
# Home page: https://metacpan.org/pod/MIME::Charset
# Download:  https://cpan.metacpan.org/authors/id/N/NE/NEZUMI/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
