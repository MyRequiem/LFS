#! /bin/bash

PRGNAME="meson"

### Meson (A high performance build system)
# Система сборки, ориентированная на скорость и на максимальное удобство для
# пользователя

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

python3 setup.py build || exit 1

# пакет не содержит набора тестов

# по умолчанию python3 setup.py install устанавливает различные файлы
# (например, man-страницы) в Python Eggs. С указаннием --root=dest, setup.py
# устанавливает эти файлы в стандартной иерархии
#    --root=dest
python3 setup.py install --root=dest
/bin/cp -vR dest/* "${TMP_DIR}"

/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (A high performance build system)
#
# Meson is a cross-platform build system designed to be both as fast and as
# user friendly as possible. It supports many languages and compilers,
# including GCC and Clang. Its build definitions are written in a simple
# non-turing complete domain specific language.
#
# Home page: https://mesonbuild.com
# Download:  https://github.com/mesonbuild/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
