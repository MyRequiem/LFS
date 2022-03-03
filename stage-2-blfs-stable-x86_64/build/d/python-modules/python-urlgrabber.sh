#! /bin/bash

PRGNAME="python-urlgrabber"
ARCH_NAME="urlgrabber"

### python-urlgrabber (python url-fetching module)
# Python2 модуль, который значительно упрощает выборку URL из файлов.
# Предназначен для использования в программах, которым нужны общие (но не
# обязательно простые) функции извлечения URL

# Required:    python-pycurl
#              python-six
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

python2 setup.py build || exit 1
python2 setup.py install --optimize=1 --root="${TMP_DIR}"

python3 setup.py build || exit 1
python3 setup.py install --optimize=1 --root="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share/doc/${ARCH_NAME}-${VERSION}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (python url-fetching module)
#
# urlgrabber is a pure python package that drastically simplifies the fetching
# of files. It is designed to be used in programs that need common (but not
# necessarily simple) url-fetching features. It is extremely simple to drop
# into an existing program and provides a clean interface to
# protocol-independant file-access. Best of all, urlgrabber takes care of all
# those pesky file-fetching details, and lets you focus on whatever it is that
# your program is written to do!
#
# Home page: https://pypi.org/project/${ARCH_NAME}/
# Download:  https://files.pythonhosted.org/packages/b1/23/61cb4d829138f24bfae2c77af6794ddd67240811dbb4e3e2eb22c4f57742/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
