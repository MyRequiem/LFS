#! /bin/bash

PRGNAME="cbindgen"

### Cbindgen (generating C bindings for Rust code)
# генерация C-bindings для Rust кода

# Required:    rustc
# Recommended: no
# Optional:    no

###
# NOTE
###
#    Для сборки требуется сеть Internet, поэтому СОБИРАЕМ ТОЛЬКО В ЧИСТОЙ LFS
#    системе (не в chroot хоста)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/usr/bin"

cargo build --release || exit 1
# cargo test --release
install -Dm755 target/release/cbindgen "${TMP_DIR}/usr/bin/"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (generating C bindings for Rust code)
#
# Cbindgen can be used to generate C bindings for Rust code
#
# Home page: https://github.com/mozilla/${PRGNAME}/
# Download:  https://github.com/mozilla/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
