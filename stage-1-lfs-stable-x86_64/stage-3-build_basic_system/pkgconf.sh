#! /bin/bash

PRGNAME="pkgconf"

### Pkg-config (system for managing library compile/link flags)
# Утилита, помогающая компилятору находить нужные библиотеки в системе для
# правильной сборки программ и их выполнения.

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# Циклическая зависимость с пакетом meson.
MESON_VERSION="$(echo "${SOURCES}/meson"-*.tar.?z* | rev | \
    cut -d . -f 3- | cut -d - -f 1 | rev)"

tar -xvf "${SOURCES}/meson-${MESON_VERSION}.tar.gz" || exit 1

mkdir build
cd build || exit 1

python3 "../meson-${MESON_VERSION}/meson.py" setup \
    --prefix=/usr       \
    --buildtype=release \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

ln -sv "${PRGNAME}"   "${TMP_DIR}/usr/bin/pkg-config"
ln -sv "${PRGNAME}.1" "${TMP_DIR}/usr/share/man/man1/pkg-config.1"

source "${ROOT}stripping.sh"      || exit 1
source "${ROOT}update-info-db.sh" || exit 1
source "${ROOT}clean-locales.sh"  || exit 1
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
