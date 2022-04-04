#! /bin/bash

PRGNAME="perl-pod-simple"
ARCH_NAME="Pod-Simple"

### Pod::Simple (framework for parsing Pod)
# Perl модуль

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

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
# Package: ${PRGNAME} (framework for parsing Pod)
#
# Pod::Simple is a Perl library for parsing text in the Pod ("plain old
# documentation") markup language that is typically used for writing
# documentation for Perl and for Perl modules. The Pod format is explained in
# perlpod; the most common formatter is called perldoc
#
# Home page: https://metacpan.org/dist/${ARCH_NAME}
# Download:  https://cpan.metacpan.org/authors/id/K/KH/KHW/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
