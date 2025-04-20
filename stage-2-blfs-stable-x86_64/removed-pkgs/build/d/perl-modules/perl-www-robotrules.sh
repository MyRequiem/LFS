#! /bin/bash

PRGNAME="perl-www-robotrules"
ARCH_NAME="WWW-RobotRules"

### WWW::RobotRules (database of robots.txt-derived permissions)
# WWW::RobotRules Perl модуль

# Required:    perl-libwww-perl
# Recommended: no
# Optional:    no

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
# Package: ${PRGNAME} (database of robots.txt-derived permissions)
#
# WWW::RobotRules parses robots.txt files, creating a WWW::RobotRules object
# with methods to check if access to a given URL is prohibited
#
# Home page: https://metacpan.org/pod/WWW::RobotRules
# Download:  https://cpan.metacpan.org/authors/id/G/GA/GAAS/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
