#! /bin/bash

PRGNAME="perl-config-autoconf"
ARCH_NAME="Config-AutoConf"

### Config::AutoConf (a module to implement some of autoconf macros in pure perl)
# Config::AutoConf Perl модуль

# Required:    perl-capture-tiny
#              perl-file-slurper
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
# Package: ${PRGNAME} (a module to implement some of autoconf macros in pure perl)
#
# The Config::AutoConf module implements some of the AutoConf macros (detecting
# a command, detecting a library, etc.) in pure perl
#
# Home page: https://metacpan.org/pod/Config::AutoConf
# Download:  https://cpan.metacpan.org/authors/id/A/AM/AMBS/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
