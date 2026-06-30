#! /bin/bash

PRGNAME="libfyaml"

### libfyaml (Fast YAML 1.2 parser and manipulator)
# Быстрая библиотека на языке C для парсинга, валидации и манипуляции файлами в
# формате YAML, полностью поддерживающая спецификацию YAML 1.2. Работает со
# сложными структурами данных напрямую без полной загрузки в оперативную
# память, что делает её идеальной для обработки огромных конфигурационных
# файлов. Является современной альтернативой libyaml.

# Required:    no
# Recommended: libyaml                      (для поддержки YAML 0.1)
# Optional:    --- для документации ---
#              git
#              python3-sphinx
#              python3-sphinx-rtd-theme
#              --- для тестов ---
#              docker                       (https://www.docker.com/)
#              jq                           (https://jqlang.org/)
#              check                        (https://libcheck.github.io/check/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Fast YAML 1.2 parser and manipulator)
#
# libfyaml is a fast and fully compliant YAML 1.2 parser, emitter, and
# manipulator library written in C. It supports the complete YAML 1.2
# specification, successfully passing 100% of the test suite. Designed with a
# high-performance DOM-like core, it allows direct data manipulation, zero-copy
# operations using mmap, and preserves formatting and comments during
# round-tripping. Includes a feature-rich CLI tool for validation and querying.
#
# Home page: https://github.com/pantoniou/${PRGNAME}/
# Download:  https://github.com/pantoniou/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
