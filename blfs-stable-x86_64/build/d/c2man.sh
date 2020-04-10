#! /bin/bash

PRGNAME="c2man"

### c2man (extracts comments from C source code)
# Инструмент для извлечения комментариев из исходного кода C для генерации
# документации

# нет в LFS и BLFS

# Home page: http://www.ciselant.de/c2man/c2man.html
# Download:  http://download.openpkg.org/components/cache/c2man/c2man-2.0@42.tar.gz

# Required: no
# Optional: no

ROOT="/"
source "${ROOT}check_environment.sh" || exit 1

SOURCES="/sources"
BUILD_DIR="${SOURCES}/build"
mkdir -p "${BUILD_DIR}"

ARCH="$(find ${SOURCES} -type f -name "c2man-*")"
VERSION="$(echo "${ARCH}" | rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

cd "${BUILD_DIR}" || exit 1
rm -rf "${PRGNAME}-${VERSION}"
mkdir "${PRGNAME}-${VERSION}"
tar -C "${PRGNAME}-${VERSION}" \
    -xvf "${SOURCES}/${PRGNAME}-${VERSION}"*.tar.?z* || exit 1
cd "${PRGNAME}-${VERSION}" || exit 1

NVERSION="${VERSION//@/.}"
TMP_DIR="/tmp/pkg-${PRGNAME}-${NVERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"/usr/{bin,lib,share/man/man1}

# самая идиотская конфигурация, которую я когда-либо видел. Происходит в
# интерактивном режиме и требует ответы на кучу вопросов, поэтому избегаем всех
# вопросов (-d) для генерации Makefile по умолчанию, а потом приведем Makefile
# в соответствие требованиям LFS системы. В конце конфигурации жмем <Enter>
sh ./Configure -d

# правим сгенерированный Makefile
sed -i "s#^bin=.*#bin=/usr/bin#"                  Makefile || exit 1
sed -i "s#^privlib=.*#privlib=/usr/lib/c2man#"    Makefile || exit 1
sed -i "s#^mansrc=.*#mansrc=/usr/share/man/man1#" Makefile || exit 1
sed -i "s#^LDFLAGS=.*#LDFLAGS= -L/usr/lib#"       Makefile || exit 1

make         || exit 1
make install || exit 1
chmod 644 "/usr/lib/c2man/eg"/*

# правим сгенерированный Makefile
sed -i "s#^bin=.*#bin=${TMP_DIR}/usr/bin#"                  Makefile || exit 1
sed -i "s#^privlib=.*#privlib=${TMP_DIR}/usr/lib/c2man#"    Makefile || exit 1
sed -i "s#^mansrc=.*#mansrc=${TMP_DIR}/usr/share/man/man1#" Makefile || exit 1

make clean
make         || exit 1
make install || exit 1
chmod 644 "${TMP_DIR}/usr/lib/c2man/eg"/*

cat << EOF > "/var/log/packages/${PRGNAME}-${NVERSION}"
# Package: ${PRGNAME} (extracts comments from C source code)
#
# c2man is an automatic documentation tool that extracts comments from C source
# code to generate functional interface documentation in the same format as
# sections 2 & 3 of the Unix Programmer's Manual. Acceptable documentation can
# often be generated from existing code with no modifications.
#
# Home page: http://www.ciselant.de/${PRGNAME}/${PRGNAME}.html
# Download:  http://download.openpkg.org/components/cache/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${NVERSION}"
