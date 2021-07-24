#! /bin/bash

PRGNAME="dconf"

### DConf (low-level configuration system)
# Низкоуровневая система настройки Glib (бэкэнд для GSettings API в GLib).
# DConf-Editor - графический редактор для базы данных DConf

# Required:    dbus
#              glib
#              gtk+3           (для сборки dconf-editor)
#              libxml2         (для сборки dconf-editor)
# Recommended: libxslt
#              vala
# Optional:    gtk-doc
#              bash-completion (https://github.com/scop/bash-completion)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

GTK_DOC="false"
BASH_COMPLETION="false"

# command -v gtkdoc-check &>/dev/null && GTK_DOC="true"
[ -f /usr/share/pkgconfig/bash-completion.pc ] && BASH_COMPLETION="true"

mkdir build
cd build || exit 1

meson                                    \
    --prefix=/usr                        \
    -Dgtk_doc="${GTK_DOC}"               \
    -Dbash_completion=${BASH_COMPLETION} \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# установим dconf-editor
DCONF_EDITOR="$(find "${SOURCES}" -type f -name "${PRGNAME}-editor-*")"
EDITOR_VERSION="$(echo "${DCONF_EDITOR}" | rev | cut -d . -f 3- | \
    cut -d - -f 1 | rev)"

TMP_DIR_EDITOR="${BUILD_DIR}/package-${PRGNAME}-editor-${EDITOR_VERSION}"
mkdir -pv "${TMP_DIR_EDITOR}"

cd "${BUILD_DIR}" || exit 1
tar -xvf "${DCONF_EDITOR}"
cd "${PRGNAME}-editor-${EDITOR_VERSION}" || exit 1

mkdir build
cd build || exit 1

meson             \
    --prefix=/usr \
    .. || exit 1

ninja || exit 1
DESTDIR="${TMP_DIR_EDITOR}" ninja install

# stripping
BINARY="$(find "${TMP_DIR_EDITOR}" -type f -print0 | \
    xargs -0 file 2>/dev/null | /bin/grep -e "executable" -e "shared object" | \
    /bin/grep ELF | /bin/grep -v "32-bit" | cut -f 1 -d :)"

for BIN in ${BINARY}; do
    strip --strip-unneeded "${BIN}"
done

/bin/cp -vpR "${TMP_DIR_EDITOR}"/* /

/bin/cp -vpR "${TMP_DIR_EDITOR}"/* "${TMP_DIR}"/

source "${ROOT}/update-info-db.sh" || exit 1

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
MAJ_VERSION_EDITOR="$(echo "${EDITOR_VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (low-level configuration system)
#
# The DConf package contains a low-level configuration system. Its main purpose
# is to provide a backend to GSettings API in GLib on platforms that dont
# already have configuration storage systems. The DConf-Editor, as the name
# suggests, is a graphical editor for the DConf database. Installation is
# optional, because gsettings from GLib-2.66.7 provides similar functionality
# on the commandline.
#
# Home page: http://live.gnome.org/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#            https://download.gnome.org/sources/${PRGNAME}-editor/${MAJ_VERSION_EDITOR}/${PRGNAME}-editor-${EDITOR_VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
