#! /bin/bash

PRGNAME="mirage"

### Mirage (GTK+ Image Viewer)
# Простой и очень быстрый просмотрщик изображений основанный на GTK, и
# написанный на Python. Умеет базово редактировать изображения (обрезка,
# поворот) и мгновенно перелистывать даже большие коллекции.

# Required:    python3-pygobject3    (собранный с cairo)
#              python3-pycairo
#              gexiv2
#              gtk+3
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим сборку с gexiv2-0.16.0
sed -i 's/0.10/0.16/' mirage/__init__.py || exit 1

python3 setup.py build || exit 1
python3 setup.py install --optimize=1 --root="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GTK+ Image Viewer)
#
# Mirage is a fast and simple GTK+ image viewer. Because it depends only on
# PyGTK, Mirage is ideal for users who wish to keep their computers lean while
# still having a clean image viewer.
#
# Home page: https://gitlab.com/thomasross/${PRGNAME}/
# Download:  https://gitlab.com/thomasross/${PRGNAME}/-/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
