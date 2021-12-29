#! /bin/bash

PRGNAME="perl-lwp-protocol-https"
ARCH_NAME="LWP-Protocol-https"

### LWP::Protocol::https (provide https support for LWP::UserAgent)
# LWP::Protocol::https Perl модуль

# Required:    perl-io-socket-ssl
#              perl-libwww-perl
#              make-ca
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# применим патч для использования системных сертификатов (при автоматической
# установке CPAN вместо этого будет использоваться Mozilla::CA, который обычно
# не обновлен и не использует локальные сертификаты)
patch --verbose -Np1 -i \
    "${SOURCES}/${ARCH_NAME}-${VERSION}-system_certs-2.patch" || exit 1

# стандартная установка
perl Makefile.PL || exit 1
make             || exit 1
# make test
make install DESTDIR="${TMP_DIR}"

# исправим пути (убираем из путей временную директорию установки пакета)
PERL_MAJ_VER="$(perl -v | /bin/grep version | cut -d \( -f 2 | cut -d v -f 2 | \
    cut -d . -f 1,2)"
PERL_MAIN_VER="$(echo "${PERL_MAJ_VER}" | cut -d . -f 1)"
PERL_LIB_PATH="/usr/lib/perl${PERL_MAIN_VER}/${PERL_MAJ_VER}"
sed -e "s|${TMP_DIR}||" -i \
    "${TMP_DIR}${PERL_LIB_PATH}/site_perl/auto/LWP/Protocol/https/.packlist"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (provide https support for LWP::UserAgent)
#
# LWP::Protocol::https provides https support for LWP::UserAgent (i.e.
# perl-libwww-perl). Once the module is installed LWP is able to access sites
# using HTTP over SSL/TLS
#
# Home page: https://metacpan.org/pod/LWP::Protocol::https
# Download:  https://www.cpan.org/authors/id/O/OA/OALDERS/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
