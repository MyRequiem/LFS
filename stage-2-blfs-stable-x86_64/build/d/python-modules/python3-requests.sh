#! /bin/bash

PRGNAME="python3-requests"
ARCH_NAME="requests"

### Requests (HTTP request library for python)
# Пожалуй, самая популярная библиотека для работы с интернетом в Python. Она
# делает отправку запросов к сайтам максимально простой и понятной даже
# новичку.

# Required:    python3-charset-normalizer
#              python3-idna
#              python3-urllib3
# Recommended: make-ca и p11-kit            (для избавления от ненужной зависимости python3-certifi)
# Optional:    --- для тестов ---
#              python3-pytest
#              python3-pysocks              (https://pypi.org/project/PySocks/)
#              python3-pytest-mock          (https://pypi.org/project/pytest-mock/)
#              python3-pytest-httpbin       (https://pypi.org/project/pytest-httpbin/)
#              python3-pytest-cov           (https://pypi.org/project/pytest-cov/)
#              python3-pytest-xdist         (https://pypi.org/project/pytest-xdist/)
#              python3-trustme              (https://pypi.org/project/trustme/)

###
# NOTE:
###
#    Можно проверить библиотеку после установки. https://httpbin.org/get -
#    сервис работает как зеркало: он просто собирает информацию о запросе и
#    отдаёт её обратно, чтобы можно было проверить, всё ли правильно улетело в
#    сеть.
#
#    >>> import requests
#    >>> response = requests.get('https://httpbin.org/get?my=test')
#    >>> print(response.status_code)
#    200
#    >>> print(response.json())
#    {
#       'args': {'my': 'test'},
#       'headers': {
#           'Accept': '*/*',
#           'Accept-Encoding': 'gzip, deflate, br, zstd',
#           'Host': 'httpbin.org',
#           'User-Agent': 'python-requests/2.34.2',
#           'X-Amzn-Trace-Id': 'Root=1-6ac375e8-743eb5dd3891c2e272ca10ed'
#       },
#       'origin': '213.88.2.183',
#       'url': 'https://httpbin.org/get'
#    }
###

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# Применим патч, чтобы переменная среды _PIP_STANDALONE_CERT, которая содержит
# путь к системным сертификатам /etc/pki/tls/certs/ca-bundle.crt и
# устанавливается после пересборки Python3 в BLFS (см. ../python3.sh), также
# могла использоваться этим модулем.
patch --verbose -Np1 -i \
    "${SOURCES}/${ARCH_NAME}-use_system_certs-2.patch" || exit 1

pip3 wheel               \
    -w dist              \
    --no-build-isolation \
    --no-deps            \
    --no-cache-dir       \
    "${PWD}" || exit 1

pip3 install            \
    --root="${TMP_DIR}" \
    --no-index          \
    --find-links dist   \
    --no-user           \
    "${ARCH_NAME}" || exit 1

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

# Если есть директория ${TMP_DIR}/usr/lib/pythonX.X/site-packages/bin/
# перемещаем ее в ${TMP_DIR}/usr/
PYTHON_MAJ_VER="$(python3 -V | cut -d ' ' -f 2 | cut -d . -f 1,2)"
TMP_SITE_PACKAGES="${TMP_DIR}/usr/lib/python${PYTHON_MAJ_VER}/site-packages"
[ -d "${TMP_SITE_PACKAGES}/bin" ] && \
    mv "${TMP_SITE_PACKAGES}/bin" "${TMP_DIR}/usr/"

# Удаляем все скомпилированные байт-коды.
rm -rf "${TMP_DIR}/usr/bin/__pycache__"
rm -rf "${TMP_SITE_PACKAGES}/__pycache__"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
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
