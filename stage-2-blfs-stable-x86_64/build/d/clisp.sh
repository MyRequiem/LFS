#! /bin/bash

PRGNAME="clisp"

### Clisp (a Common Lisp implementation)

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"


DESTDIR="${TMP_DIR}" ninja install
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a Common Lisp implementation)
#
#
#
# Home page:
# Download:
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

# echo -e "\n---------------\nRemoving *.la files..."
# remove-la-files.sh
# echo "---------------"

# MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"

# mkdir build
# cd build || exit 1
# meson             \
#     --prefix=/usr \
#     -D<param>     \
#     ...
#     .. || exit 1
#
# ninja || exit 1

# source "${ROOT}/config_file_processing.sh"             || exit 1
# CONFIG="...."
# if [ -f "${CONFIG}" ]; then
#     mv "${CONFIG}" "${CONFIG}.old"
# fi
# config_file_processing "${CONFIG}"

# https://www.x.org
# source "${ROOT}/xorg_config.sh"                        || exit 1
# # shellcheck disable=SC2086
# ./configure \
#     ${XORG_CONFIG} || exit 1

# SOURCES="${ROOT}/src"
# VERSION="$(find "${SOURCES}" -type f \
#     -name "${SRC_ARCH_NAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
#     rev | cut -d . -f 3- | cut -d - -f 1 | rev)"
#
# BUILD_DIR="/tmp/build-${SRC_ARCH_NAME}-${VERSION}"
# rm -rf "${BUILD_DIR}"
# mkdir -pv "${BUILD_DIR}"
# cd "${BUILD_DIR}" || exit 1
#
# tar xvf "${SOURCES}/${SRC_ARCH_NAME}-${VERSION}"*.tar.?z* || exit 1
# cd "${SRC_ARCH_NAME}-${VERSION}" || exit 1


Beyond Linux^® From Scratch (System V Edition) - Version 11.3

Chapter 13. Programming

  • Prev

    Cbindgen-0.24.3

  • Next

    CMake-3.25.2

  • Up
  • Home

Clisp-2.49

Introduction to Clisp

GNU Clisp is a Common Lisp implementation which includes an interpreter,
compiler, debugger, and many extensions.

This package is known to build and work properly using an LFS 11.3 platform.

Package Information

  • Download (HTTP): https://ftp.gnu.org/gnu/clisp/latest/clisp-2.49.tar.bz2

  • Download (FTP): ftp://ftp.gnu.org/gnu/clisp/latest/clisp-2.49.tar.bz2

  • Download MD5 sum: 1962b99d5e530390ec3829236d168649

  • Download size: 7.8 MB

  • Estimated disk space required: 163 MB (add 8 MB for tests)

  • Estimated build time: 0.9 SBU (1.2 SBU with tests)

Additional Downloads

  • Optional patch: https://www.linuxfromscratch.org/patches/blfs/11.3/
    clisp-2.49-readline7_fixes-1.patch (required if building against libffcall)

Clisp Dependencies

Recommended

libsigsegv-2.14

Optional

libnsl-2.0.0 and libffcall

User Notes: https://wiki.linuxfromscratch.org/blfs/wiki/clisp

Installation of Clisp

[Note]

Note

This package does not support parallel build.

If you are building on a 32-bit system, work around a bug in GCC caused by the
latest version of binutils:

case $(uname -m) in
    i?86) export CFLAGS="${CFLAGS:--O2 -g} -falign-functions=4" ;;
esac

Remove two tests, which fail for unknown reasons:

sed -i -e '/socket/d' -e '/"streams"/d' tests/tests.lisp

Install Clisp by running the following commands:

If you are building clisp against libffcall, apply the patch to fix a build
failure with current readline:

patch -Np1 -i ../clisp-2.49-readline7_fixes-1.patch

Install Clisp by running the following commands:

mkdir build &&
cd    build &&

../configure --srcdir=../                       \
             --prefix=/usr                      \
             --docdir=/usr/share/doc/clisp-2.49 \
             --with-libsigsegv-prefix=/usr &&

ulimit -s 16384 &&
make -j1

To test the results, issue: make check.

Now, as the root user:

make install

Command Explanations

ulimit -s 16384: this increases the maximum stack size, as recommended by the
configure.

--docdir=/usr/share/doc/clisp-2.49: this ensures the html documentation will go
into a versioned directory instead of straight into /usr/share/html/.

--with-libsigsegv-prefix=/usr: use this to tell configure that you have
installed libsigsegv in /usr, otherwise it will not be found.

--with-libffcall-prefix=/usr: use this to tell configure that you have
installed the optional libffcall in /usr, otherwise like libsigsegv it will not
be found.

Contents

Installed Programs: clisp, clisp-link
Installed Libraries: various static libraries in /usr/lib/clisp-2.49/base/
Installed Directories: /usr/lib/clisp-2.49 /usr/share/doc/clisp-2.49 /usr/share
/emacs/site-lisp;

Short Descriptions

clisp      is an ANSI Common Lisp compiler, interpreter, and debugger

clisp-link is used to link an external module to clisp

  • Prev

    Cbindgen-0.24.3

  • Next

    CMake-3.25.2

  • Up
  • Home

