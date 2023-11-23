#! /bin/bash

PRGNAME="python2-pygtk"
ARCH_NAME="pygtk"

### PyGTK (GTK+ bindings for Python)
# Набор оболочек Python для библиотеки графического интерфейса GTK+

# Required:    python2
#              gtk+2
#              python2-pygobject2
#              atk
#              pango
#              python2-pycairo
#              libglade
# Recommended: no
# Optional:    python3-numpy
#              libxslt (для сборки документации)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# адаптируем PyGTK к изменениям в Pango, удалив неопределенные API
sed -i '1394,1402 d' pango.defs || exit 1

DOCS="--disable-docs"
NUMPY="--disable-numpy"

# command -v xslt-config &>/dev/null && DOCS="--enable-docs"
command -v f2py        &>/dev/null && NUMPY="--enable-numpy"

./configure       \
    --prefix=/usr \
    "${DOCS}"     \
    "${NUMPY}" || exit 1

make || exit 1

# тесты должны запускаться при запущенном сеансе X
# make check

make install DESTDIR="${TMP_DIR}"

[[ "x${DOCS}" == "x--disable-docs" ]] && rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GTK+ bindings for Python)
#
# PyGTK lets you to easily create programs with a graphical user interface
# using the Python programming language. Provides a convenient wrapper for the
# GTK+ library for use in Python programs, taking care of many of the boring
# details such as managing memory and type casting.
#
# Home page: http://www.${ARCH_NAME}.org/
# Download:  https://download.gnome.org/sources/${ARCH_NAME}/${MAJ_VERSION}/${ARCH_NAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
