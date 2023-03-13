#! /bin/bash

PRGNAME="wheel"

###  Wheel (a built-package format for Python)
# Python библиотека, которая является эталонной реализацией стандарта создания
# Python пакетов. Утилита wheel служит для упаковки, раскаповки и конвертации
# wheel-архивов

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
PYTHON_MAJ_VER="$(python3 -V | cut -d ' ' -f 2 | cut -d . -f 1,2)"
SITE_PACKAGES="/usr/lib/python${PYTHON_MAJ_VER}/site-packages"
mkdir -pv "${TMP_DIR}${SITE_PACKAGES}"

# позволяет пакету (еще не установленному) создавать для себя архив, чтобы
# избежать проблемы "курицы или яйца"
#    PYTHONPATH=src
# команда создает архив для этого пакета
#    wheel
# инструктирует pip поместить созданный пакет в указанный каталог dist
#    -w "${TMP_DIR}"
# предотвращаем получение файлов из онлайн-репозитория пакетов (PyPI). Если
# пакеты установлены в правильном порядке, pip вообще не нужно будет извлекать
# какие-либо файлы
#    --no-build-isolation
#    --no-deps
PYTHONPATH=src pip3 ${PRGNAME} -w dist --no-build-isolation --no-deps "${PWD}"

# устанавливаем в "${TMP_DIR}"
pip3 install -t "${TMP_DIR}/usr" --no-index --find-links=dist ${PRGNAME}

# перемещаем директории
mv "${TMP_DIR}/usr/${PRGNAME}"                      "${TMP_DIR}${SITE_PACKAGES}"
mv "${TMP_DIR}/usr/${PRGNAME}-${VERSION}.dist-info" "${TMP_DIR}${SITE_PACKAGES}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a built-package format for Python)
#
# Wheel is a Python library that is the reference implementation of the Python
# wheel packaging standard
#
# Home page: https://pypi.org/project/${PRGNAME}/
# Download:  https://pypi.org/packages/source/w/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
