#! /bin/bash

PRGNAME="gedit"

### Gedit (GNOME Text Editor)
# Простой, но мощный графический текстовый редактор для Linux, являющийся
# стандартным для среды рабочего стола GNOME, который отлично подходит как для
# обычных заметок, так и для написания кода благодаря поддержке подсветки
# синтаксиса (Python, C++, HTML и др.), нумерации строк, вкладок и возможности
# расширения функционала плагинами, обеспечивая при этом чистый интерфейс и
# поддержку Юникода

# Required:    gsettings-desktop-schemas
#              gtk+3
#              itstool
#              libhandy
#              libpeas
#              libxml2
# Recommended: gspell
#              gvfs                         (runtime)
#              iso-codes
#              python3-pygobject3
# Optional:    gtk-doc
#              vala
#              valgrind
#              zeitgeist                    (https://launchpad.net/zeitgeist)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# для сборки требуются некоторые библиотеки, основанные на GTK+3 и являющиеся
# частью Gedit Technology
#    libgedit-amtk              - Actions, Menus and Toolbars Kit
#    libgedit-gtksourceview     - Source code editing widget
#    libgedit-gfls              - File loading and saving
#    libgedit-tepl              - Text editor product line

LIBS="\
libgedit-amtk \
libgedit-gtksourceview \
libgedit-gfls \
libgedit-tepl \
"

for LIB in ${LIBS}; do
    LIBARCH="$(find "${SOURCES}" -type f -name "${LIB}-*" | rev | \
        cut -d / -f 1 | rev)"

    # оставляем только имя директории в архиве, например
    #    libgedit-amtk-5.9.1.tar.bz2 -> libgedit-amtk-5.9.1
    PKGDIR="${LIBARCH%.tar*}"

    [ -z "${PKGDIR}" ] && {
        echo "Archive ${LIBS} not found in ${SOURCES}"
        exit 1
    }

    tar -xvf "${SOURCES}/${LIBARCH}" || exit 1

    pushd "${PKGDIR}"
    # директория build уже существует в архиве (с одним файлом .gitignore)
    cd build

    meson setup ..          \
        --prefix=/usr       \
        --buildtype=release \
        -D gtk_doc=false || exit 1

    ninja || exit 1
    # ninja test 2>&1 | tee ../../$packagedir-test.log
    DESTDIR="${TMP_DIR}" ninja install

    popd

    rm -rf "${PKGDIR}"
done

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

# устанавливаем библиотеки в систему
source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# собираем gedit
cd build || exit 1

meson setup ..          \
    --prefix=/usr       \
    --buildtype=release \
    -D gtk_doc=false || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# обновим файлы схем GLib
glib-compile-schemas /usr/share/glib-2.0/schemas

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GNOME Text Editor)
#
# The Gedit package contains a lightweight UTF-8 text editor for the GNOME
# Desktop. It needs a group of packages to be installed before Gedit itself.
# This page will install all of them
#
# Home page: https://${PRGNAME}-text-editor.org/
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
