#! /bin/bash

PRGNAME="perl-anyevent-i3"
ARCH_NAME="AnyEvent-I3"

### AnyEvent::I3 (communicate with the i3 window manager)
# AnyEvent::I3 Perl модуль

# Required:    perl-anyevent
#              perl-json-xs
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
# Package: ${PRGNAME} (communicate with the i3 window manager)
#
# This module connects to the i3 window manager using the UNIX socket based IPC
# interface it provides (if enabled in the configuration file). You can then
# subscribe to events or send messages and receive their replies.
#
# Home page: https://metacpan.org/pod/AnyEvent::I3
# Download:  https://cpan.metacpan.org/authors/id/M/MS/MSTPLBG/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
