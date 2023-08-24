#! /bin/bash

PRGNAME="python3-cachecontrol"
ARCH_NAME="CacheControl"

### CacheControl (caching algorithms for use with requests session object)
# Алгоритмы кэширования в httplib2 для использования с объектами модуля
# requests

# Required:    python3-msgpack
#              python3-requests
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# сборка с помощью модуля build (пакет python3-build) и установка с помощью
# модуля installer (пакет python3-installer)
python3 -m build --no-isolation                           || exit 1
python3 -m installer -d "${TMP_DIR}" \
    ./dist/"${ARCH_NAME}-${VERSION}-py2.py3-none-any.whl" || exit 1

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (caching algorithms for use with requests session object)
#
# CacheControl is a port of the caching algorithms in httplib2 for use with
# requests session object.
#
# Home page: https://pypi.org/project/${ARCH_NAME}/
# Download:  https://anduin.linuxfromscratch.org/BLFS/${ARCH_NAME}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
