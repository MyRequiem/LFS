#! /bin/bash

PRGNAME="perl"

### Perl
# Practical Extraction and Report Language

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

MAJ_VER="$(echo "${VERSION}" | cut -d . -f 1)"
MAJ_MIN_VER="$(echo "${VERSION}" | cut -d . -f 1,2)"

# -des - это сочетание трех параметров:
#     -d    - использовать значения по умолчанию для всех элементов
#     -e    - обеспечивает выполнение всех заданий
#     -s    - заставляет "замолчать" несущественный вывод
sh Configure                                                         \
    -des                                                             \
    -Dprefix=/usr                                                    \
    -Dvendorprefix=/usr                                              \
    -Dprivlib="/usr/lib/perl${MAJ_VER}/${MAJ_MIN_VER}/core_perl"     \
    -Darchlib="/usr/lib/perl${MAJ_VER}/${MAJ_MIN_VER}/core_perl"     \
    -Dsitelib="/usr/lib/perl${MAJ_VER}/${MAJ_MIN_VER}/site_perl"     \
    -Dsitearch="/usr/lib/perl${MAJ_VER}/${MAJ_MIN_VER}/site_perl"    \
    -Dvendorlib="/usr/lib/perl${MAJ_VER}/${MAJ_MIN_VER}/vendor_perl" \
    -Dvendorarch="/usr/lib/perl${MAJ_VER}/${MAJ_MIN_VER}/vendor_perl" || exit 1

make || make -j1 || exit 1
make install
