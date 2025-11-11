#! /bin/bash

PRGNAME="dconf"

### DConf (low-level configuration system)
# Низкоуровневая система настройки Glib (бэкэнд для GSettings API в GLib).
# DConf-Editor - графический редактор для базы данных DConf

# Required:    dbus
#              glib
#              --- для сборки dconf-editor ---
#              gtk+3
#              libhandy
#              libxml2
# Recommended: libxslt
#              vala
# Optional:    gtk-doc
#              bash-completion (https://github.com/scop/bash-completion)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# предотвратим установку ненужных модулей systemd
sed -i 's/install_dir: systemd_userunitdir,//' service/meson.build || exit 1

mkdir build
cd build || exit 1

meson setup                 \
    --prefix=/usr           \
    --buildtype=release     \
    -D bash_completion=true \
    .. || exit 1

ninja || exit 1

# тесты проводятся в графической среде
# dbus-run-session ninja test

DESTDIR="${TMP_DIR}" ninja install

# сразу установим, т.к. dconf нужен для сборки dconf-editor
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# собираем dconf-editor
DCONF_EDITOR="$(find "${SOURCES}" -type f -name "${PRGNAME}-editor-*")"
EDITOR_VERSION="$(echo "${DCONF_EDITOR}" | rev | cut -d . -f 3- | \
    cut -d - -f 1 | rev)"

cd .. || exit 1
tar -xvf "${DCONF_EDITOR}"
cd "${PRGNAME}-editor-${EDITOR_VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

mkdir build
cd build || exit 1

meson setup             \
    --prefix=/usr       \
    --buildtype=release \
    .. || exit 1

ninja || exit 1
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
MAJ_VERSION_EDITOR="$(echo "${EDITOR_VERSION}" | cut -d . -f 1)"
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
# Home page: https://live.gnome.org/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#            https://download.gnome.org/sources/${PRGNAME}-editor/${MAJ_VERSION_EDITOR}/${PRGNAME}-editor-${EDITOR_VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
