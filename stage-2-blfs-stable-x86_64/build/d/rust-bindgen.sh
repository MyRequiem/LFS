#! /bin/bash

PRGNAME="rust-bindgen"

### rust-bindgen (generating Rust bindings from C/C++ headers)
# генерирование Rust-bindings из заголовков C/C ++

# Required:    rustc
#              llvm
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
install -v -m755 target/release/bindgen /usr/bin/
install -v -m755 target/release/bindgen "${TMP_DIR}/usr/bin/"

BASH_COMPL="/usr/share/bash-completion/completions"
mkdir -p "${TMP_DIR}${BASH_COMPL}"
bindgen --generate-shell-completions bash > "${TMP_DIR}${BASH_COMPL}/bindgen"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (generating Rust bindings from C/C++ headers)
#
# The rust-bindgen package contains a utility that generates Rust bindings from
# C/C++ headers
#
# Home page: https://github.com/rust-lang/${PRGNAME}/
# Download:  https://github.com/rust-lang/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
