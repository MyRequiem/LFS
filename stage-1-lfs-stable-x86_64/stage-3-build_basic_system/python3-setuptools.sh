#! /bin/bash

PRGNAME="python3-setuptools"
ARCH_NAME="setuptools"

### python3-setuptools (a collection of enhancements to Python distutils)
# Python3 библиотека, предназначенная для облегчения упаковки проектов в пакеты

ROOT="/"
source "${ROOT}check_environment.sh"                    || exit 1
source "${ROOT}unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

###
# создаем пакет в формате .whl в директории dist дерева исходников
#    wheel-${VERSION}-py3-none-any.whl
###
# команда создает архив для этого пакета
#    wheel
# инструктирует pip поместить созданный пакет в указанный каталог dist
#    --wheel-dir=./dist
# не устанавливать зависимости для пакета
#    --no-deps
# предотвращаем получение файлов из онлайн-репозитория пакетов (PyPI). Если
# пакеты установлены в правильном порядке, pip вообще не нужно будет извлекать
# какие-либо файлы
#    --no-build-isolation
pip3 wheel               \
    --wheel-dir=./dist   \
    --no-cache-dir       \
    --no-build-isolation \
    --no-deps            \
    ./ || exit 1

# устанавливаем созданный пакет в "${TMP_DIR}"
pip3 install            \
    --root="${TMP_DIR}" \
    --find-links=./dist \
    --no-index "${ARCH_NAME}" || exit 1

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a collection of enhancements to Python distutils)
#
# This is a full featured library designed to facilitate packaging Python
# projects. Features include Python package and module definitions,
# distribution package metadata, test hooks, project installation, and
# platform-specific details.
#
# Home page: https://pypi.python.org/pypi/${ARCH_NAME}
# Download:  https://pypi.org/packages/source/s/${ARCH_NAME}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
