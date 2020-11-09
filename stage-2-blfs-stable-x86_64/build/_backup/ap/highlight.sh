#! /bin/bash

PRGNAME="highlight"

### Highlight (converts sources to text with syntax highlighting)
# утилита для преобразования исходного кода в форматированный текст с
# подсветкой синтаксиса

# http://www.linuxfromscratch.org/blfs/view/stable/general/highlight.html

# Home page: http://www.andre-simon.de/index.php
# Download:  http://www.andre-simon.de/zip/highlight-3.55.tar.bz2

# Required: boost
#           lua
# Optional: qt5 (для сборки GUI интерфейса)

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# не сжимаем man-страницы
sed -i '/GZIP/s/^/#/' makefile || exit 1
# установим правильный путь для документации
sed -i "s#^doc_dir = .*#doc_dir = \${PREFIX}/share/doc/${PRGNAME}-${VERSION}#" \
    makefile || exit 1
sed -i "s#^examples_dir = .*/#examples_dir = \${doc_dir}/extras/#" \
    makefile || exit 1

QT5=""
command -v assistant &>/dev/null && QT5="true"

make
[ -n "${QT5}" ] && make gui

# пакет не содержит набора тестов

CONFIG="/etc/highlight/filetypes.conf"
if [ -f "${CONFIG}" ]; then
    mv "${CONFIG}" "${CONFIG}.old"
fi

make install
make install DESTDIR="${TMP_DIR}"

if [ -n "${QT5}" ]; then
    make install-gui
    make install-gui DESTDIR="${TMP_DIR}"
fi

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
