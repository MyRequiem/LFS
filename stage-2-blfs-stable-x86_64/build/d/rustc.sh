#! /bin/bash

PRGNAME="rustc"
BLFS_VER="13.0"

### Rustc (The Rust programming language)
# Компилятор современного языка программирования Rust. Он славится тем, что
# помогает создавать очень быстрые и максимально защищенные от ошибок
# программы.

# Required:    cmake
#              curl
# Recommended: libssh2
#              llvm
# Optional:    gdb          (для тестов)
#              git          (для тестов)
#              cranelift    (https://github.com/bytecodealliance/wasmtime/tree/main/cranelift)
#              jemalloc     (https://jemalloc.net/)
#              libgccjit    (GCC собранный с параметром --enable-languages=jit)
#              libgit2      (https://libgit2.org/)

###
# WARNING
###
#  * Перед обновлением пакета старую версию нужно удалить из системы.
#  * Требуется интернет подключение, поэтому пакет собираем в ЧИСТОЙ LFS
#       системе (не в chroot). Rustc нуждается в некоторых бинарниках для
#       сборки, которые будут загружаться из сети.

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

INSTALLED="$(find /var/log/packages/ -type f -name "rustc-*")"
if [ -n "${INSTALLED}" ]; then
    INSTALLED_VERSION="$(echo "${INSTALLED}" | rev | cut -d / -f 1 | rev)"
    echo "${PRGNAME} version ${INSTALLED_VERSION} already installed."
    echo "Before building ${PRGNAME} package, you need to remove it."
    removepkg --no-color "${INSTALLED}"
fi

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${PRGNAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 2 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}-${VERSION}"*.tar.?z* || exit 1
cd "${PRGNAME}-${VERSION}-src" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \+ -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \+

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# конфиг для сборки
cat << EOF > config.toml
# See bootstrap.toml.example for more possible options, and see
# src/bootstrap/defaults/bootstrap.dist.toml for a few options automatically
# set when building from a release tarball (unfortunately, we have to override
# many of them).

# Tell x.py that the editors have reviewed the content of this file and updated
# it to follow the major changes of the building system, so x.py will not warn
# users to review that information.
change-id = 148671

[llvm]
# When using the system installed copy of LLVM, prefer the shared libraries
link-shared = true

# If building the shipped LLVM source, only enable the x86 target instead of
# all the targets supported by LLVM.
targets = "X86"

[build]
description = "for BLFS ${BLFS_VER}"

# Omit the documentation to save time and space (the default is to build them).
docs = false

# Do not look for new versions of the dependencies online.
locked-deps = true

# Only install these extended tools. Cargo, clippy, rustdoc, and rustfmt are
# installed by a default rustup installation, and rust-src is needed to build
# the Rust code in Linux kernel (in case you need such a kernel feature).
tools = ["cargo", "clippy", "rustdoc", "rustfmt", "src"]

[install]
prefix = "/usr"
docdir = "share/doc/${PRGNAME}-${VERSION}"

[rust]
channel = "stable"

# Enable the same optimizations as the official upstream build.
lto = "thin"
codegen-units = 1

# Don't build llvm-bitcode-linker which is only useful for the NVPTX backend
# that we don't enable.
llvm-bitcode-linker = false

[target.x86_64-unknown-linux-gnu]
llvm-config = "/usr/bin/llvm-config"

[target.i686-unknown-linux-gnu]
llvm-config = "/usr/bin/llvm-config"
EOF

### сборка
export LIBSSH2_SYS_USE_PKG_CONFIG=1
export LIBSQLITE3_SYS_USE_PKG_CONFIG=1
./x.py build || exit 1

### тесты
# SSL_CERT_DIR=/etc/ssl/certs \
# ./x.py test --verbose --no-fail-fast | tee rustc-testlog
#
# проверка результатов:
# grep '^test result:' rustc-testlog | \
#     awk '{sum1 += $4; sum2 += $6} END { print sum1 " passed; " sum2 " failed" }'

DESTDIR="${TMP_DIR}" ./x.py install

unset LIB{SSH2,SQLITE3}_SYS_USE_PKG_CONFIG

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

rm -rf /root/.cargo

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (The Rust programming language)
#
# The Rust programming language is designed to be a safe, concurrent, practical
# language.
#
# Home page: https://www.rust-lang.org/
# Download:  https://static.rust-lang.org/dist/${PRGNAME}-${VERSION}-src.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
