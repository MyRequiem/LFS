#! /bin/bash

PRGNAME="imake"

### imake (C preprocessor interface to the make utility)
# Генерирует Makefile из шаблонов Imakefile

# Required:    xorg-cf-files
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure              \
    --prefix=/usr        \
    --sysconfdir=/etc    \
    --localstatedir=/var \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (C preprocessor interface to the make utility)
#
# imake generates makefiles from a template, a set of C preprocessor macro
# functions, and a per-directory input file called an Imakefile. This allows
# machine dependencies (such as compiler options, alternate command names, and
# special make rules) to be kept separate from the descriptions of the various
# items to be built. Package contains the imake utility, plus the following
# support programs: ccmakedep, mergelib, revpath, mkdirhier, makeg, cleanlinks,
# mkhtmlindex, xmkmf
#
# Home page: https://www.x.org/archive/individual/util/
# Download:  https://www.x.org/archive/individual/util/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
