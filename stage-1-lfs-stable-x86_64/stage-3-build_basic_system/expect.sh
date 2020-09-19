#! /bin/bash

PRGNAME="expect"

### Expect (program that talks to other interactive programs)
# Пакет содержит утилиту для ведения диалоговых сценариев с другими
# интерактивными программами такими как telnet, ftp, passwd, fsck, rlogin, tip
# и т.д. Пакет также полезен для тестирования приложений.

# http://www.linuxfromscratch.org/lfs/view/stable/chapter08/expect.html

# Home page: https://core.tcl.tk/expect/

ROOT="/"
source "${ROOT}check_environment.sh" || exit 1

SOURCES="${ROOT}sources"
VERSION=$(echo "${SOURCES}/${PRGNAME}"*.tar.?z* | rev | cut -d / -f 1 | \
    cut -d . -f 3- | rev | cut -d t -f 2)

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}${DOCS}"

BUILD_DIR="${SOURCES}/build"
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1
rm -rf "${PRGNAME}${VERSION}"

tar xvf "${SOURCES}/${PRGNAME}${VERSION}".tar.?z* || exit 1
cd "${PRGNAME}${VERSION}" || exit 1

# указывает где находится конфигурационный скрипт tclConfig.sh из пакета tcl
#    --with-tcl=/usr/lib
# явно указываем, где искать внутренние заголовки Tcl
#    --with-tclinclude=/usr/include
./configure                        \
    --prefix=/usr                  \
    --with-tcl=/usr/lib            \
    --enable-shared                \
    --mandir=/usr/share/man        \
    --with-tclinclude=/usr/include \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || make -j1 || exit 1

# запускаем тестовый набор
# make test

make install DESTDIR="${TMP_DIR}"

# ссылка в /usr/lib
#    libexpect${VERSION}.so -> expect${VERSION}/libexpect${VERSION}.so
ln -svf "expect${VERSION}/libexpect${VERSION}.so" "${TMP_DIR}/usr/lib"

# документация
cp ChangeLog FAQ NEWS README "${TMP_DIR}${DOCS}/"

/bin/cp -vR "${TMP_DIR}"/* /

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

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
