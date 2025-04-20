#! /bin/bash

PRGNAME="mujs"

### MuJS (embeddable Javascript interpreter)
# Облегченный интерпретатор Javascript, встраиваемый в другое программное
# обеспечение для расширения его возможностей. Написан на Portable C и
# реализует ECMAScript, в соответствии с ECMA-262. Почему? Потому что V8,
# SpiderMonkey, mozjs, nodejs, JavaScriptCore слишком большие и сложные. MuJS
# фокусируется на небольшом размере и простоте.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

make shared || exit 1
make prefix=/usr install-shared DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (embeddable Javascript interpreter)
#
# MuJS is a lightweight Javascript interpreter designed for embedding in other
# software to extend them with scripting capabilities. It is written in
# portable C and implements ECMAScript as specified by ECMA-262. Why? Because
# V8, SpiderMonkey, mozjs, nodejs, JavaScriptCore are all too big and complex.
# MuJS's focus is on small size, correctness and simplicity.
#
# Home page: https://${PRGNAME}.com/
# Download:  https://${PRGNAME}.com/downloads/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
