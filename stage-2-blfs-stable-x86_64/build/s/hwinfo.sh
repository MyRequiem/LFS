#! /bin/bash

PRGNAME="hwinfo"

### hwinfo (Hardware detection tool)
# Утилита, обнаруживающая и отображающая оборудование компьютера (hardware)

# Required:    libx86emu
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
MANDIR="/usr/share/man"
mkdir -pv "${TMP_DIR}${MANDIR}/"{man1,man8}

# исправим CFLAGS
sed -i "s/?= -O2/?= -O2 -fPIC/" Makefile.common

# отключаем генерацию файлов changelog и VERSION
chmod -x ./git2log
echo "${VERSION}" > VERSION

# собираем в один поток
make -j1 LIBDIR=/usr/lib                              || exit 1
make -j1 LIBDIR=/usr/lib install DESTDIR="${TMP_DIR}" || exit 1

(
    cd "${TMP_DIR}" || exit 1
    rm -rf sbin
)

# man-страницы
install -m 644 "doc/${PRGNAME}.8" "${TMP_DIR}${MANDIR}/man8/"
install -m 644 doc/*.1            "${TMP_DIR}${MANDIR}/man1/"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Hardware detection tool)
#
# hwinfo is a simple program that lists results from the hardware detection
# library.
#
# Home page: https://github.com/openSUSE/${PRGNAME}
# Download:  https://github.com/openSUSE/${PRGNAME}/archive/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
