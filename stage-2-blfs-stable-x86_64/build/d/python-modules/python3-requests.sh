#! /bin/bash

PRGNAME="python3-requests"
ARCH_NAME="requests"

### Requests (HTTP request library for python)
# Python-библиотека HTTP-запросов

# Required:    python3-charset-normalizer
#              python3-idna
#              python3-urllib3
# Recommended: make-ca
#              p11-kit
# Optional:    --- для тестов ---
#              python3-pytest
#              python3-pysocks                      (https://pypi.org/project/PySocks/)
#              python3-flask           version<2    (https://pypi.org/project/Flask/)
#              python3-httpbin                      (https://pypi.org/project/httpbin/)
#              python3-markupsafe      version<2.1  (https://pypi.org/project/MarkupSafe/)
#              python3-pytest-mock                  (https://pypi.org/project/pytest-mock/)
#              python3-pytest-httpbin               (https://pypi.org/project/pytest-httpbin/)
#              python3-sphinx          version<5    (https://pypi.org/project/Sphinx/)
#              python3-trustme                      (https://pypi.org/project/trustme/)
#              python3-werkzeug        version<2    (https://pypi.org/project/Werkzeug/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# применим патч, чтобы переменная среды _PIP_STANDALONE_CERT, которая содержит
# путь к системным сертификатам /etc/pki/tls/certs/ca-bundle.crt и
# устанавливается после пересборки Python3 в BLFS (см. build/d/python3.sh),
# также могла использоваться этим модулем
patch --verbose -Np1 -i \
    "${SOURCES}/${ARCH_NAME}-${VERSION}-use_system_certs-1.patch" || exit 1

# сборка с помощью модуля build (пакет python3-build) и установка с помощью
# модуля installer (пакет python3-installer)
python3 -m build --no-isolation                       || exit 1
python3 -m installer -d "${TMP_DIR}" \
    ./dist/"${ARCH_NAME}-${VERSION}-py3-none-any.whl" || exit 1

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
# Download:  https://files.pythonhosted.org/packages/source/r/${ARCH_NAME}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
