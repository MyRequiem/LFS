#! /bin/bash

PRGNAME="duktape"

### Duktape (embeddable Javascript engine)
# Встраиваемый Javascript-движок. Легко интегрируется в проекты C/C++

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

sed -i 's/-Os/-O2/' Makefile.sharedlibrary         || exit 1
make -f Makefile.sharedlibrary INSTALL_PREFIX=/usr || exit 1
make -f Makefile.sharedlibrary INSTALL_PREFIX=/usr install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (embeddable Javascript engine)
#
# Duktape is an embeddable Javascript engine, with a focus on portability and
# compact footprint. Duktape is easy to integrate into a C/C++ project: add
# duktape.c, duktape.h, and duk_config.h to your build, and use the Duktape API
# to call ECMAScript functions from C code and vice versa.
#
# Home page: https://${PRGNAME}.org/
# Download:  https://${PRGNAME}.org/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
