#! /bin/bash

PRGNAME="python-py3c"
ARCH_NAME="py3c"

### python-py3c (Python 2/3 compatibility layer for C extensions)
# помогает портировать расширения C на Python 3

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# пакет содержит только C-заголовочные файлы и устанавливает их в
# /usr/include/py3c и поэтому не требует настройки и компиляции

# make test-python3
make prefix=/usr install DESTDIR="${TMP_DIR}"

/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Python 2/3 compatibility layer for C extensions)
#
# Py3c helps you port C extensions to Python 3. It provides a detailed guide,
# and a set of macros to make porting easy and reduce boilerplate
#
# Home page: https://pypi.org/project/${ARCH_NAME}/
# Download:  https://github.com/encukou/${ARCH_NAME}/archive/v${VERSION}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
