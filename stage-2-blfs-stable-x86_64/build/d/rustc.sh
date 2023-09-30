#! /bin/bash

PRGNAME="rustc"

### Rustc (The Rust programming language)
# Язык программирования Rust

# Required:    cmake
# Recommended: curl
#              libssh2
#              llvm
# Optional:    gdb     (для тестов)
#              libgit2 (https://libgit2.org/)

# NOTES:
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

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# конфиг для сборки
cat << EOF > config.toml
# see config.toml.example for more possible options

# tell x.py to not keep printing an annoying warning
changelog-seen = 2

[llvm]
# by default, rust will build for a myriad of architectures
targets = "X86"

# When using system llvm prefer shared libraries
link-shared = true

[build]
# omit docs to save time and space (default is to build them)
docs = false

# install extended tools: cargo, clippy, etc.
extended = true

# do not query new versions of dependencies online
locked-deps = true

# specify which extended tools (those from the default install)
tools = ["cargo", "clippy", "rustfmt"]

# use the source code shipped in the tarball for the dependencies: the
# combination of this and the "locked-deps" entry avoids downloading many
# crates from internet, and makes the rustc build more stable.
vendor = true

[install]
prefix = "/usr"
docdir = "share/doc/${PRGNAME}-${VERSION}"

[rust]
channel = "stable"
description = "for BLFS 11.3"

# BLFS used to not install the FileCheck executable from llvm, so disabled
# codegen tests.  The assembly tests rely on FileCheck and cannot easily be
# disabled, so those will anyway fail if FileCheck has not been installed
codegen-tests = false

[target.x86_64-unknown-linux-gnu]
# NB the output of llvm-config (i.e. help options) may be dumped to the screen
# when config.toml is parsed.
llvm-config = "/usr/bin/llvm-config"

[target.i686-unknown-linux-gnu]
# NB the output of llvm-config (i.e. help options) may be dumped to the screen
# when config.toml is parsed.
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

# сборка
{
    [ ! -e /usr/include/libssh2.h ] || export LIBSSH2_SYS_USE_PKG_CONFIG=1;
} && python3 ./x.py build

# тесты
# python3 ./x.py test --verbose --no-fail-fast | tee rustc-testlog
#
# количество неудачных тестов:
# grep '^test result:' rustc-testlog | \
#   awk '{sum1 += $4; sum2 += $6} END { print sum1 " passed; " sum2 " failed" }'

# установка
export LIBSSH2_SYS_USE_PKG_CONFIG=1
DESTDIR="${TMP_DIR}" python3 ./x.py install
unset LIBSSH2_SYS_USE_PKG_CONFIG

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
