#! /bin/bash

PRGNAME="c2man"

### c2man (extracts comments from C source code)
# Инструмент для извлечения комментариев из исходного кода C для генерации
# документации

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
ARCH="$(find "${SOURCES}" -type f -name "c2man-*")"
ARCH_VERSION="$(echo "${ARCH}" | rev | cut -d . -f 3- | cut -d - -f 1 | rev)"
VERSION="${ARCH_VERSION//@/.}"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"/usr/{bin,lib,share/man/man1}

cd "${BUILD_DIR}" || exit 1
mkdir "${PRGNAME}-${VERSION}"
cd "${PRGNAME}-${VERSION}" || exit 1
tar xvf "${ARCH}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

# конфигурация происходит в интерактивном режиме и требует ответы на кучу
# вопросов, поэтому избегаем всех вопросов (-d) для генерации Makefile по
# умолчанию, а потом приведем Makefile в соответствие требованиям LFS системы.
# В конце конфигурации жмем <Enter>
sh ./Configure -d

# правим сгенерированный Makefile
sed -i "s#^bin=.*#bin=${TMP_DIR}/usr/bin#"                  Makefile || exit 1
sed -i "s#^privlib=.*#privlib=${TMP_DIR}/usr/lib/c2man#"    Makefile || exit 1
sed -i "s#^mansrc=.*#mansrc=${TMP_DIR}/usr/share/man/man1#" Makefile || exit 1
sed -i "s#^LDFLAGS=.*#LDFLAGS= -L/usr/lib#"                 Makefile || exit 1

make         || exit 1
make install || exit 1
chmod 644 "${TMP_DIR}/usr/lib/c2man/eg"/*

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (extracts comments from C source code)
#
# c2man is an automatic documentation tool that extracts comments from C source
# code to generate functional interface documentation in the same format as
# sections 2 & 3 of the Unix Programmer's Manual. Acceptable documentation can
# often be generated from existing code with no modifications.
#
# Home page: http://www.ciselant.de/${PRGNAME}/${PRGNAME}.html
# Download:  http://download.openpkg.org/components/cache/${PRGNAME}/${PRGNAME}-${ARCH_VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
