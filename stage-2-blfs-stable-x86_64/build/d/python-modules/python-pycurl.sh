#! /bin/bash

PRGNAME="python-pycurl"
ARCH_NAME="pycurl"

### python-pycurl (Python interface to cURL library)
# Python интерфейс для libcurl

# Required:    no
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

rm -rf "${TMP_DIR}/usr/share/doc/pycurl"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Python interface to cURL library)
#
# PycURL is a Python interface to libcurl. PycURL can be used to fetch objects
# identified by a URL from a Python program, similar to the urllib Python
# module. PycURL is mature, very fast, and supports a lot of features.
#
# Home page: http://${ARCH_NAME}.sourceforge.net
# Download:  https://files.pythonhosted.org/packages/47/f9/c41d6830f7bd4e70d5726d26f8564538d08ca3a7ac3db98b325f94cdcb7f/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
