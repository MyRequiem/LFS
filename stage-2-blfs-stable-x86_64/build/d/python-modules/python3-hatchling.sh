#! /bin/bash

PRGNAME="python3-hatchling"
ARCH_NAME="hatchling"

### Hatchling (Hatch build backend)
# расширяемый, совместимый со стандартами сервер сборки, используемый Hatch

# Required:    python3-build
#              python3-editables
#              python3-packaging
#              python3-pathspec
#              python3-pluggy
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

###
# сборка средствами модуля wheel
# создаем пакет в формате .whl в директории dist дерева исходников
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
pip3 install            \
    --root="${TMP_DIR}" \
    --find-links=./dist \
    --no-cache-dir      \
    --no-user           \
    --no-index "${ARCH_NAME}" || exit 1

# если есть директория ${TMP_DIR}/usr/lib/pythonX.X/site-packages/bin/
# перемещаем ее в ${TMP_DIR}/usr/
PYTHON_MAJ_VER="$(python3 -V | cut -d ' ' -f 2 | cut -d . -f 1,2)"
TMP_SITE_PACKAGES="${TMP_DIR}/usr/lib/python${PYTHON_MAJ_VER}/site-packages"
[ -d "${TMP_SITE_PACKAGES}/bin" ] && \
    mv "${TMP_SITE_PACKAGES}/bin" "${TMP_DIR}/usr/"

# удаляем все скомпилированные байт-коды из ${TMP_DIR}/usr/bin/, если таковые
# имеются
PYCACHE="${TMP_DIR}/usr/bin/__pycache__"
[ -d "${PYCACHE}" ] && rm -rf "${PYCACHE}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Hatch build backend)
#
# This is the extensible, standards compliant build backend used by Hatch
#
# Home page: https://pypi.org/project/${ARCH_NAME}/
# Download:  https://files.pythonhosted.org/packages/source/h/${ARCH_NAME}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"