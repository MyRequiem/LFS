#! /bin/bash

PRGNAME="perl-text-bibtex"
ARCH_NAME="Text-BibTeX"

### Text::BibTeX (interface to read and parse BibTeX files)
# Text::BibTeX Perl модуль

# Required:    perl-config-autoconf
#              perl-extutils-libbuilder
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# установка с помощью модуля Build (пакет perl-module-build)
perl Build.PL || exit 1
./Build       || exit 1
# ./Build test
./Build install destdir="${TMP_DIR}"

# удалим perllocal.pod и другие служебные файлы, которые не нужно устанавливать
find "${TMP_DIR}" \
    \( -name perllocal.pod -o -name ".packlist" -o -name "*.bs" \) \
    -exec rm {} \;

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (interface to read and parse BibTeX files)
#
# Text::BibTeX provides an interface to read and parse BibTeX files
#
# Home page: https://metacpan.org/pod/Text::BibTeX
# Download:  https://www.cpan.org/authors/id/A/AM/AMBS/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
