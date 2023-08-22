#! /bin/bash

PRGNAME="python3-attrs"
ARCH_NAME="attrs"

### Attrs (attributes without boilerplate)
# Декораторы классов Python, упрощающие рутинную работу по реализации наиболее
# распространенных объектных протоколов, связанных с атрибутами.

# Required:    no
# Recommended: no
# Optional:    === для тестов ===
#              python3-pytest
#              python3-coverage             (https://pypi.org/project/coverage/)
#              python3-hypothesis           (https://pypi.org/project/hypothesis/)
#              python3-pympler              (https://pypi.org/project/Pympler/)
#              python3-mypy                 (https://pypi.org/project/mypy/)
#              python3-pytest-mypy-plugins  (https://pypi.org/project/pytest-mypy-plugins/)
#              python3-zope-interface       (https://pypi.org/project/zope.interface/)
#              python3-cloudpickle          (https://pypi.org/project/cloudpickle/)

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
# Package: ${PRGNAME} (attributes without boilerplate)
#
# Attrs is an MIT-licensed Python package with class decorators that ease the
# chores of implementing the most common attribute-related object protocols.
#
# Home page: https://pypi.org/project/${ARCH_NAME}/
# Download:  https://files.pythonhosted.org/packages/source/a/${ARCH_NAME}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
