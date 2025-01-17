#! /bin/bash

PRGNAME="perl-class-data-inheritable"
ARCH_NAME="Class-Data-Inheritable"

### Class::Data::Inheritable (inheritable, overridable class data)
# Class::Data::Inheritable Perl модуль

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
# Package: ${PRGNAME} (inheritable, overridable class data)
#
# Class::Data::Inheritable is for creating accessor/mutators to class data.
# That is, if you want to store something about your class as a whole (instead
# of about a single object)
#
# Home page: https://metacpan.org/pod/Class::Data::Inheritable
# Download:  https://cpan.metacpan.org/authors/id/R/RS/RSHERER/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
