#! /bin/bash

PRGNAME="popt"

### Popt (command line parsing library)
# C-библиотека для анализа параметров командной строки, используемая некоторыми
# программами для их разбора.

# Required:    no
# Recommended: no
# Optional:    doxygen (для сборки документации)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VER="$(echo "${VERSION}" | cut -d . -f 1)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (command line parsing library)
#
# Popt is a C library for parsing command line parameters and used by some
# programs to parse command-line options. Popt was popt: heavily influenced by
# the getopt() and getopt_long() functions, but it popt: improves on them by
# allowing more powerful argument expansion. Popt popt: can parse arbitrary
# argv[] style arrays and automatically set popt: variables based on command
# line arguments. Popt allows command line popt: arguments to be aliased via
# configuration files and includes utility popt: functions for parsing
# arbitrary strings into argv[] arrays using popt: shell-like rules.
#
# Home page: http://ftp.rpm.org/${PRGNAME}/releases/
# Download:  https://ftp.osuosl.org/pub/rpm/${PRGNAME}/releases/${PRGNAME}-1.x/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
