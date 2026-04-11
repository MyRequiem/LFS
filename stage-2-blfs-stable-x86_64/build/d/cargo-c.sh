#! /bin/bash

PRGNAME="cargo-c"

### cargo-c (cargo applet to build and install C-ABI libraries)
# Вспомогательный инструмент для разработчиков на Rust. Он позволяет собирать
# Rust-библиотеки так, чтобы их понимали старые добрые программы, написанные на
# C.

# Required:    rustc
# Recommended: libssh2
# Optional:    no

###
# NOTE:
#    для сборки требуется интернет подключение, собираем в ЧИСТОЙ LFS системе
#    (не в chroot)
###

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/usr/bin/"

# загрузим файл определения версий для зависимостей, которые будут скачиваться
# во время сборки
HOME_PAGE="https://github.com/lu-zero/${PRGNAME}"
# curl -fLO "${HOME_PAGE}/releases/download/v${VERSION}/Cargo.lock"
wget "${HOME_PAGE}/releases/download/v${VERSION}/Cargo.lock" || exit 1

export LIBSSH2_SYS_USE_PKG_CONFIG=1
export LIBSQLITE3_SYS_USE_PKG_CONFIG=1

cargo build --release || exit 1
# cargo test --release
install -vm755 target/release/cargo-{capi,cbuild,cinstall,ctest} \
    "${TMP_DIR}/usr/bin/"

unset LIB{SSH2,SQLITE3}_SYS_USE_PKG_CONFIG

# очистим rust кэш, мусор не нужен
rm -rf /root/.cargo

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (cargo applet to build and install C-ABI libraries)
#
# cargo applet to build and install C-ABI compatible dynamic and static
# libraries.
#
# It produces and installs a correct pkg-config file, a static library and a
# dynamic library, and a C header to be used by any C (and C-compatible)
# software.
#
# Home page: ${HOME_PAGE}
# Download:  ${HOME_PAGE}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
