#! /bin/bash

PRGNAME="python3-lxml"
ARCH_NAME="lxml"

### python3-lxml (Python bindings for libxml2 and libxslt)
# Python bindings для библиотек libxml2 и libxslt

# Required:    libxslt
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

###
# создаем в директории dist дерева исходников пакет
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
    --no-deps            \
    --no-build-isolation \
    ./ || exit 1

### устанавливаем созданный пакет в "${TMP_DIR}"
# отключает кеш, чтобы предотвратить предупреждение при установке от
# пользователя root
#    --no-cache-dir
# предотвращает ошибочный запуск команды установки от имени обычного
# пользователя без полномочий root
#    --no-user
PYTHON_MAJ_VER="$(python3 -V | cut -d ' ' -f 2 | cut -d . -f 1,2)"
TARGET="${TMP_DIR}/usr/lib/python${PYTHON_MAJ_VER}/site-packages"
pip3 install             \
    --target="${TARGET}" \
    --find-links=./dist  \
    --no-cache-dir       \
    --no-user            \
    --no-index ${ARCH_NAME}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Python bindings for libxml2 and libxslt)
#
# lxml is a Pythonic binding for the libxml2 and libxslt libraries. It is
# unique in that it combines the speed and feature completeness of these
# libraries with the simplicity of a native Python API
#
# Home page: https://${ARCH_NAME}.de/
# Download:  https://files.pythonhosted.org/packages/source/l/${ARCH_NAME}/${ARCH_NAME}-${VERSION}.tar.gz
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
