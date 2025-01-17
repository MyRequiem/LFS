#! /bin/bash

PRGNAME="py3c"

### Py3c (Python 2/3 compatibility layer for C extensions)
# Помогает портировать C-расширения на Python 3

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# пакет содержит только C-заголовочные файлы и устанавливает их в
# /usr/include/py3c/ и поэтому не требует конфигурации и компиляции

# тесты
# make test-python3
# make test-python3-cpp

make prefix=/usr install DESTDIR="${TMP_DIR}"

/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Python 2/3 compatibility layer for C extensions)
#
# Py3c helps you port C extensions to Python 3. It provides a detailed guide,
# and a set of macros to make porting easy and reduce boilerplate
#
# Home page: https://pypi.org/project/${PRGNAME}/
# Download:  https://github.com/encukou/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
