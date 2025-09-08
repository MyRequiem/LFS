#! /bin/bash

PRGNAME="rustc"

### Rustc (The Rust programming language)
# Язык программирования Rust

# Required:    cmake
#              curl
# Recommended: libssh2
#              llvm
#              sqlite
# Optional:    ---  ---
#              gdb          (для тестов)
#              git          (для тестов)
#              cranelift    (https://github.com/bytecodealliance/wasmtime/tree/main/cranelift)
#              jemalloc     (https://jemalloc.net/)
#              libgccjit    (GCC собранный с параметром --enable-languages=jit)
#              libgit2      (https://libgit2.org/)

###
# WARNING
###
#  * Перед обновлением пакета старую версию нужно удалить из системы.
#  * Требуется интернет подключение. Rustc нуждается в некоторых бинарниках
#    для сборки, поэтому во время сборки архивы с нужными файлами будут
#    загружаться из сети.

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
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/usr"/{bin,share/man/man1,share/zsh/site-functions}

# конфиг для сборки
cat << EOF > config.toml
# see config.toml.example for more possible options
# See the 8.4 book for an old example using shipped LLVM
# e.g. if not installing clang, or using a version before 13.0

# Tell x.py the editors have reviewed the content of this file
# and updated it to follow the major changes of the building system,
# so x.py will not warn us to do such a review.
change-id = 125535

[llvm]
# by default, rust will build for a myriad of architectures
targets = "X86"

# When using system llvm prefer shared libraries
link-shared = true

[build]
# omit docs to save time and space (default is to build them)
docs = false

# install extended tools: cargo, clippy, etc
extended = true

# Do not query new versions of dependencies online.
locked-deps = true

# Specify which extended tools (those from the default install).
tools = ["cargo", "clippy", "rustdoc", "rustfmt"]

# Use the source code shipped in the tarball for the dependencies.
# The combination of this and the "locked-deps" entry avoids downloading
# many crates from Internet, and makes the Rustc build more stable.
vendor = true

[install]
prefix = "/usr"
docdir = "share/doc/${PRGNAME}-${VERSION}"

[rust]
channel = "stable"
description = "for BLFS 12.4"

# Enable the same optimizations as the official upstream build.
lto = "thin"
codegen-units = 1

[target.x86_64-unknown-linux-gnu]
# NB the output of llvm-config (i.e. help options) may be
# dumped to the screen when config.toml is parsed.
llvm-config = "/usr/bin/llvm-config"

[target.i686-unknown-linux-gnu]
# NB the output of llvm-config (i.e. help options) may be
# dumped to the screen when config.toml is parsed.
llvm-config = "/usr/bin/llvm-config"
EOF

# отключим проверку SSL сертификатов (добавим опцию '-k') для 'curl' при
# скачивании архивов, иначе при сборке в chroot среде curl выдает ошибку:
# ***
# curl: (60) server certificate verification failed. CAfile: none CRLfile: none
# More details here: https://curl.se/docs/sslcerts.html
#
# curl failed to verify the legitimacy of the server and therefore could not
# establish a secure connection to it. To learn more about this situation and
# how to fix it, please visit the web page mentioned above.
# ***
sed -i 's/"-y", "30"/"-k", "-y", "30"/' src/bootstrap/bootstrap.py || exit 1

### сборка
{
    [ ! -e /usr/include/libssh2.h ] || export LIBSSH2_SYS_USE_PKG_CONFIG=1;
} &&
{
    [ ! -e /usr/include/sqlite3.h ] || export LIBSQLITE3_SYS_USE_PKG_CONFIG=1;
} && python3 x.py build

### тесты
# SSL_CERT_DIR=/etc/ssl/certs                                     \
# python3 x.py test --verbose --no-fail-fast --keep-stage-std=1 | \
#     tee rustc-testlog

# количество неудачных тестов:
# grep '^test result:' rustc-testlog |
#    awk '{sum1 += $4; sum2 += $6} END { print sum1 " passed; " sum2 " failed" }'

# установка
export LIBSSH2_SYS_USE_PKG_CONFIG=1
export LIBSQLITE3_SYS_USE_PKG_CONFIG=1
DESTDIR="${TMP_DIR}" python3 x.py install rustc std

install -vm755 \
    build/host/stage1-tools/*/*/{cargo{,-clippy,-fmt},clippy-driver,rustfmt} \
    "${TMP_DIR}/usr/bin"|| exit 1

install -vDm644 \
    src/tools/cargo/src/etc/_cargo \
    "${TMP_DIR}/usr/share/zsh/site-functions/_cargo" || exit 1

install -vm644 src/tools/cargo/src/etc/man/* \
    "${TMP_DIR}/usr/share/man/man1"
unset LIBSSH2_SYS_USE_PKG_CONFIG LIBSQLITE3_SYS_USE_PKG_CONFIG

# исправим установку документации
rm -f "${TMP_DIR}/usr/share/doc/${PRGNAME}-${VERSION}"/*.old
install -vm644 README.md "${TMP_DIR}/usr/share/doc/${PRGNAME}-${VERSION}/"

chmod 755 "${TMP_DIR}/usr/lib/lib"*

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
