#! /bin/bash

PRGNAME="python3-editables"
ARCH_NAME="editables"

### Editables (A Python library for creating "editable wheels")
# Python библиотека для создания "editable wheels". Другими словами изменения в
# исходниках Python пакета будут отражены в пакете visible без переустановки

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

##
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
    --no-index "${ARCH_NAME}"

# если есть директория ${TMP_DIR}/usr/lib/pythonX.X/site-packages/bin/
# перемещаем ее в ${TMP_DIR}/usr/ и удаляем все скомпилированные байт-коды
[ -d "${TARGET}/bin" ] && mv "${TARGET}/bin" "${TMP_DIR}/usr/"
rm -rfv "${TMP_DIR}/usr/bin/__pycache__"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (A Python library for creating "editable wheels")
#
# This library supports the building of wheels which, when installed, will
# expose packages in a local directory on sys.path in "editable mode". In other
# words, changes to the package source will be reflected in the package visible
# to Python, without needing a reinstall.
#
# Home page: https://pypi.org/project/${ARCH_NAME}/
# Download:  https://files.pythonhosted.org/packages/source/e/${ARCH_NAME}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
