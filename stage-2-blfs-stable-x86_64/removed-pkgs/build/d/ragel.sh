#! /bin/bash

PRGNAME="ragel"

### ragel (State Machine Compiler)
# Генератор программного кода на языках C, C++, Objective-C, D, Ruby или Java

# Required:    colm
#              kelbt
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure          \
    --prefix=/usr    \
    --with-colm=/usr \
    --disable-static \
    --disable-manual \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (State Machine Compiler)
#
# Ragel compiles executable finite state machines from regular languages. Ragel
# targets C, C++, Objective-C, D, Java and Ruby. Ragel state machines can not
# only recognize byte sequences as regular expression machines do, but can also
# execute code at arbitrary points in the recognition of a regular language.
# Code embedding is done using inline operators that do not disrupt the regular
# language syntax.
#
# Home page: https://www.colm.net/open-source/${PRGNAME}/
# Download:  https://www.colm.net/files/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
