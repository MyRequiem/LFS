#! /bin/bash

PRGNAME="giflib"

### giflib (Graphics Interchange Format image library)
# Легковесная и проверенная временем библиотека и утилиты, созданные специально
# для работы с форматом GIF (Graphics Interchange Format). Позволяют программам
# быстро открывать, создавать и редактировать анимированные и статичные
# изображения этого типа.

# Required:    no
# Recommended: no
# Optional:    xmlto    (нужен при запуске 'make' после 'make clean')

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

make || exit 1
# make check
make            \
    PREFIX=/usr \
    DOCDIR="/usr/share/doc/${PRGNAME}-${VERSION}" install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

# удалим статическую библиотеку
rm -f "${TMP_DIR}/usr/lib/libgif.a"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Graphics Interchange Format image library)
#
# The giflib package contains libraries for reading and writing GIF (Graphics
# Interchange Format) as well as programs for converting and working with GIF
# files
#
# Home page: https://${PRGNAME}.sourceforge.net/
# Download:  https://sourceforge.net/projects/${PRGNAME}/files/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
