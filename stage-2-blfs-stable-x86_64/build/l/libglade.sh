#! /bin/bash

PRGNAME="libglade"

### libglade (GLADE Interface Designer library)
# Библиотека GLADE позволяет загружать файлы пользовательских интерфейсов,
# которые хранятся во внешней программе, что позволяет изменять интерфейс
# программы без ее перекомпиляции. Библиотека так же позволяет редактировать
# интерфейсы.

# Required:    libxml2
#              gtk+2
# Recommended: no
# Optional:    python2 (требуется для работы утилиты 'libglade-convert') https://www.python.org/downloads/release/python-2718/
#              gtk-doc

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

GTK_DOC="--disable-gtk-doc"
# command -v gtkdoc-check  &>/dev/null && GTK_DOC="--enable-gtk-doc"

# некоторые из функций glib, которые использует libglade, были объявлены
# устаревшими в glib-2.30 и следующая команда удаляет флаг G_DISABLE_DEPRECATED
sed -i '/DG_DISABLE_DEPRECATED/d' glade/Makefile.in || exit 1

./configure       \
    --prefix=/usr \
    "${GTK_DOC}"  \
    --disable-static || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

[[ "x${GTK_DOC}" == "x--disable-gtk-doc" ]] && \
    rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GLADE Interface Designer library)
#
# The GLADE library allows loading user interfaces which are stored externally
# into a program. This allows the interface to be changed without recompiling
# the program. The interfaces can also be edited with GLADE.
#
# Home page: https://glade.gnome.org/
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
