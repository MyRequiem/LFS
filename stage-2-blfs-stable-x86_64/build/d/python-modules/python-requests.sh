#! /bin/bash

PRGNAME="python-requests"
ARCH_NAME="requests"

### python-requests (HTTP request library for python)
# Python-библиотека HTTP-запросов

# Required:    python2
#              python3
#              python-certifi
#              python-chardet
#              python3-idna
#              python-urllib3
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

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (HTTP request library for python)
#
# Requests allows you to send organic, grass-fed HTTP/1.1 requests, without the
# need for manual labor. There's no need to manually add query strings to your
# URLs, or to form-encode your POST data. Keep-alive and HTTP connection
# pooling are 100% automatic, powered by urllib3, which is embedded within
# Requests.
#
# Home page: https://pypi.org/project/${ARCH_NAME}/
# Download:  https://files.pythonhosted.org/packages/60/f3/26ff3767f099b73e0efa138a9998da67890793bfa475d8278f84a30fec77/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
