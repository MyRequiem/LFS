#! /bin/bash

PRGNAME="perl-sub-identify"
ARCH_NAME="Sub-Identify"

### Sub::Identify (retrieve the real name of code references)
# Perl модуль, позволяющий получить настоящее имя ссылок на код

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

# исправим пути (убираем из путей временную директорию установки пакета)
PERL_MAJ_VER="$(perl -v | /bin/grep version | cut -d \( -f 2 | cut -d v -f 2 | \
    cut -d . -f 1,2)"
PERL_MAIN_VER="$(echo "${PERL_MAJ_VER}" | cut -d . -f 1)"
PERL_LIB_PATH="/usr/lib/perl${PERL_MAIN_VER}/${PERL_MAJ_VER}"
sed -e "s|${TMP_DIR}||" -i \
    "${TMP_DIR}${PERL_LIB_PATH}/site_perl/auto/Sub/Identify/.packlist"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (retrieve the real name of code references)
#
# Sub::Identify allows you to retrieve the real name of code references. It
# provides six functions, all of them taking a code reference. sub_name returns
# the name of the code reference passed as an argument (or __ANON__ if it's an
# anonymous code reference), stash_name returns its package, and sub_fullname
# returns the concatenation of the two.
#
# Home page: https://metacpan.org/pod/Sub::Identify
# Download:  https://cpan.metacpan.org/authors/id/R/RG/RGARCIA/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
