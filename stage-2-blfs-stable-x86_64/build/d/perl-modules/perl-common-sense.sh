#! /bin/bash

PRGNAME="perl-common-sense"
ARCH_NAME="common-sense"

### common::sense (perl common defaults with lower memory usage)
# Небольшой модуль, который автоматически включает правильные и современные
# настройки написания кода на языке Perl. Он избавляет программиста от рутины и
# защищает от типичных старых ошибок, делая код чище.

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

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

# удалим perllocal.pod и другие служебные файлы, которые не нужно устанавливать
find "${TMP_DIR}" \
    \( -name perllocal.pod -o -name ".packlist" -o -name "*.bs" \) \
    -exec rm {} \+

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (perl common defaults with lower memory usage)
#
# common::sense module implements some sane defaults for Perl programs, as
# defined by two typical, (or not so typical - use your common sense) specimens
# of Perl coders.
#
# Home page: https://metacpan.org/pod/common::sense
# Download:  https://cpan.metacpan.org/authors/id/M/ML/MLEHMANN/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
