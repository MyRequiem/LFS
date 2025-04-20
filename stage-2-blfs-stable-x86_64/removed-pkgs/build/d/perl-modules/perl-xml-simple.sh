#! /bin/bash

PRGNAME="perl-xml-simple"
ARCH_NAME="XML-Simple"

### XML::Simple (API for simple XML files)
# XML::Simple Perl модуль

# Required:    no
# Recommended: no
# Optional:    perl-xml-sax

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# стандартная установка
perl Makefile.PL || exit 1
make             || exit 1
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
# Package: ${PRGNAME} (API for simple XML files)
#
# XML::Simple provides an easy API to read and write XML (especially config
# files). It is deprecated and its use is discouraged
#
# Home page: https://metacpan.org/pod/XML::Simple
# Download:  https://www.cpan.org/authors/id/G/GR/GRANTM/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
