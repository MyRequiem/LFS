#! /bin/bash

PRGNAME="highlight"

### Highlight (converts sources to text with syntax highlighting)
# утилита для преобразования исходного кода в форматированный текст с
# подсветкой синтаксиса

# Required:    boost
#              lua
# Recommended: no
# Optional:    qt5 (для сборки GUI интерфейса)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# не сжимаем man-страницы
sed -i '/GZIP/s/^/#/' makefile || exit 1

GUI=""
# command -v assistant &>/dev/null && GUI="true"

make || exit 1

DOCS="/usr/share/doc/${PRGNAME}-${VERSION}/"
if [ -n "${GUI}" ]; then
    make doc_dir="${DOCS}" gui || exit 1
fi

# пакет не содержит набора тестов

make doc_dir="${DOCS}" install DESTDIR="${TMP_DIR}"

if [ -n "${GUI}" ]; then
    make install-gui DESTDIR="${TMP_DIR}"
fi

CONFIG="/etc/highlight/filetypes.conf"
if [ -f "${CONFIG}" ]; then
    mv "${CONFIG}" "${CONFIG}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${CONFIG}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (converts sources to text with syntax highlighting)
#
# Highlight is an utility that converts source code to formatted text with
# syntax highlighting.
#
# Home page: http://www.andre-simon.de/index.php
# Download:  http://www.andre-simon.de/zip/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
