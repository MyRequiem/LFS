#! /bin/bash

PRGNAME="pkgconf"

### Pkg-config (system for managing library compile/link flags)
# Инструмент для передачи путей include и/или путей к библиотекам для создания
# инструментов во время настройки и выполнения файлов

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

./configure          \
    --prefix=/usr    \
    --disable-static \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || make -j1 || exit 1
make install DESTDIR="${TMP_DIR}"

ln -sv "${PRGNAME}"   "${TMP_DIR}/usr/bin/pkg-config"
ln -sv "${PRGNAME}.1" "${TMP_DIR}/usr/share/man/man1/pkg-config.1"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (system for managing library compile/link flags)
#
# pkg-config is a system for managing library compile/link flags that works
# with automake and autoconf. It replaces the ubiquitous *-config scripts you
# may have seen with a single tool. Package contains a tool for passing the
# include path and/or library paths to build tools during the configure and
# make file execution.
#
# Home page: https://www.freedesktop.org/wiki/Software/pkg-config
# Download:  https://distfiles.ariadne.space/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
