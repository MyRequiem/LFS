#! /bin/bash

PRGNAME="perl-archive-zip"
ARCH_NAME="Archive-Zip"

### Archive::Zip (create, manipulate, read, and write Zip archive)
# Perl модуль, позволяющий создавать, изменять, читать Zip-архивы

# Required:    no
# Recommended: unzip (для тестов)
# Optional:    perl-test-mockmodule

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
# Package: ${PRGNAME} (create, manipulate, read, and write Zip archive)
#
# The Archive::Zip Perl module allows a Perl program to create, manipulate,
# read, and write Zip archive files. Zip archives can be created, or you can
# read from existing zip files. Once created, they can be written to files,
# streams, or strings. Members can be added, removed, extracted, replaced,
# rearranged, and enumerated. They can also be renamed or have their dates,
# comments, or other attributes queried or modified. Their data can be
# compressed or uncompressed as needed.
#
# Home page: https://metacpan.org/pod/Archive::Zip
# Download:  https://www.cpan.org/authors/id/P/PH/PHRED/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
