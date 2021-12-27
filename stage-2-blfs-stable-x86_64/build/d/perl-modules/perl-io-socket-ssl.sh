#! /bin/bash

PRGNAME="perl-io-socket-ssl"
ARCH_NAME="IO-Socket-SSL"

### IO::Socket::SSL (SSL sockets with IO::Socket interface)
# IO::Socket::SSL Perl модуль

# Required:    make-ca
#              perl-net-ssleay
# Recommended: perl-uri         (для доступа к international domain names)
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# В процессе сборки задается вопроc, на который отвечаем yes [yes | Makefile.PL]
# Should I do external tests?
# These test will detect if there are network problems and fail soft, so please
# disable them only if you definitely don't want to have any network traffic to
# external sites [Y/n]
yes | perl Makefile.PL || exit 1
make                   || exit 1
# make test
make install DESTDIR="${TMP_DIR}"

# исправим пути (убираем из путей временную директорию установки пакета)
PERL_MAJ_VER="$(perl -v | /bin/grep version | cut -d \( -f 2 | cut -d v -f 2 | \
    cut -d . -f 1,2)"
PERL_MAIN_VER="$(echo "${PERL_MAJ_VER}" | cut -d . -f 1)"
PERL_LIB_PATH="/usr/lib/perl${PERL_MAIN_VER}/${PERL_MAJ_VER}"
sed -e "s|${TMP_DIR}||" -i \
    "${TMP_DIR}${PERL_LIB_PATH}/site_perl/auto/IO/Socket/SSL/.packlist"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (SSL sockets with IO::Socket interface)
#
# IO::Socket::SSL makes using SSL/TLS much easier by wrapping the necessary
# functionality into the familiar IO::Socket interface and providing secure
# defaults whenever possible
#
# Home page: https://metacpan.org/dist/IO-Socket-SSL/view/lib/IO/Socket/SSL.pod
# Download:  https://www.cpan.org/authors/id/S/SU/SULLR/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
