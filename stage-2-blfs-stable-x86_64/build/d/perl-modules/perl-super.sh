#! /bin/bash

PRGNAME="perl-super"
ARCH_NAME="SUPER"

### SUPER (easier methods to dispatch control to the superclass)
# Perl модуль SUPER предоставляет более простые методы для отправки управления
# суперклассу (при создании подкласса)

# Required:    no
# Recommended: perl-sub-identify (для тестов)
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
# Package: ${PRGNAME} (easier methods to dispatch control to the superclass)
#
# SUPER provides easier methods to dispatch control to the superclass (when
# subclassing a class)
#
# Home page: https://metacpan.org/pod/${ARCH_NAME}
# Download:  https://cpan.metacpan.org/authors/id/C/CH/CHROMATIC/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
