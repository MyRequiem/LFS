#! /bin/bash

PRGNAME="python3-scour"
ARCH_NAME="scour"

### Scour (Python SVG cleaner)
# Оптимизирует структуру SVG (Scalable Vector Graphics) файлов, удаляет не
# нужные данные и таким образом уменьшает их размер. Предназначен для
# использования после экспорта изображений в SVG формат в графических
# редакторах (Inkscape, Adobe и т.д.)

# Required:    python3
#              python3-six
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

python3 setup.py build || exit 1
# python3 test_scour.py
python3 setup.py install --optimize=1 --root="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Python SVG cleaner)
#
# Scour is an SVG (Scalable Vector Graphics) optimizer/cleaner that reduces
# their size by optimizing structure and removing unnecessary data. It is
# intended to be used after exporting to SVG with a GUI editor, such as
# Inkscape or Adobe Illustrator.
#
# Home page: https://pypi.org/project/${ARCH_NAME}/
# Download:  https://github.com/${ARCH_NAME}-project/${ARCH_NAME}/archive/v${VERSION}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
