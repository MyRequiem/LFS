#! /bin/bash

PRGNAME="perl-alien-build-plugin-download-gitlab"
ARCH_NAME="Alien-Build-Plugin-Download-GitLab"

### Alien::Build::Plugin::Download::GitLab (Perl plugin to download from GitLab)
# Alien::Build::Plugin::Download::GitLab Perl модуль

# Required:    perl-alien-build
#              perl-uri
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
# Package: ${PRGNAME} (Perl plugin to download from GitLab)
#
# Perl plugin to download from GitLab
#
# Home page: https://metacpan.org/pod/Alien::Build::Plugin::Download::GitLab
# Download:  https://cpan.metacpan.org/authors/id/P/PL/PLICEASE/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
