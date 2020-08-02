#! /bin/bash

PRGNAME="expect"

### Expect (program that talks to other interactive programs)
# Пакет содержит утилиту для ведения диалоговых сценариев с другими
# интерактивными программами такими как telnet, ftp, passwd, fsck, rlogin, tip
# и т.д.

# http://www.linuxfromscratch.org/blfs/view/stable/general/expect.html

# Home page: https://core.tcl.tk/expect/
# Download:  https://downloads.sourceforge.net/expect/expect5.45.4.tar.gz

# Required: tcl
# Optional: tk

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find ${SOURCES} -type f \
    -name "${PRGNAME}*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d / -f 1 | cut -d . -f 3- | rev | cut -d t -f 2)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}${VERSION}".tar.?z* || exit 1
cd "${PRGNAME}${VERSION}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure                 \
    --prefix=/usr           \
    --with-tcl=/usr/lib     \
    --enable-shared         \
    --mandir=/usr/share/man \
    --with-tclinclude=/usr/include || exit 1

make || exit 1
# make test
make install
make install DESTDIR="${TMP_DIR}"

# ссылка в /usr/lib
# libexpect${VERSION}.so -> expect${VERSION}/libexpect${VERSION}.so
ln -svf "expect${VERSION}/libexpect${VERSION}.so" /usr/lib
(
    cd "${TMP_DIR}/usr/lib" || exit 1
    ln -svf "expect${VERSION}/libexpect${VERSION}.so" "libexpect${VERSION}.so"
)

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (program that talks to other interactive programs)
#
# Expect is a program that talks to other interactive programs according to a
# script. It contains tools for automating interactive applications such as
# telnet, ftp, passwd, fsck, rlogin, tip, etc. Following the script, Expect
# knows what can be expected from a program and what the correct response
# should be. An interpreted language provides branching and high-level control
# structures to direct the dialogue.
#
# Home page: https://core.tcl.tk/${PRGNAME}/
# Download:  https://downloads.sourceforge.net/${PRGNAME}/${PRGNAME}${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
