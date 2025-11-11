#! /bin/bash

PRGNAME="cargo-c"

### cargo-c (cargo applet to build and install C-ABI libraries)
# cargo апплет для создания и установки C-ABI совместимых динамических и
# статических библиотек

# Required:    rustc
# Recommended: libssh2
#              sqlite
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
curl -fLO "${HOME_PAGE}/releases/download/v${VERSION}/Cargo.lock"

[ ! -e /usr/include/libssh2.h ] || export LIBSSH2_SYS_USE_PKG_CONFIG=1
[ ! -e /usr/include/sqlite3.h ] || export LIBSQLITE3_SYS_USE_PKG_CONFIG=1

cargo build --release
# cargo test --release
install -vm755 target/release/cargo-{capi,cbuild,cinstall,ctest} \
    "${TMP_DIR}/usr/bin/"

unset LIB{SSH2,SQLITE3}_SYS_USE_PKG_CONFIG

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
