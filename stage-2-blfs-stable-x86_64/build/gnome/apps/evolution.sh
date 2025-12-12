#! /bin/bash

PRGNAME="evolution"

### Evolution (Email and calendaring application)
# Официальное приложение для управления личной информацией (PIM) в среде
# рабочего стола GNOME, которое объединяет функции почтового клиента,
# календаря, адресной книги, списка задач (To-Do) и заметок, предлагая
# функциональность, аналогичную Microsoft Outlook, и поддерживая стандартные
# протоколы и синхронизацию с корпоративными серверами, такими как Microsoft
# Exchange

# Required:    adwaita-icon-theme
#              evolution-data-server
#              gcr4
#              gnome-autoar
#              shared-mime-info
#              webkitgtk
# Recommended: bogofilter
#              enchant
#              gnome-desktop
#              gspell
#              highlight
#              itstool
#              libcanberra
#              libgweather
#              libnotify
#              openldap
#              seahorse
# Optional:    geocode-glib
#              gtk-doc
#              --- для сборки Contact Maps plugin ---
#              clutter-gtk              (https://gitlab.gnome.org/Archive/clutter-gtk)
#              cmark                    (https://github.com/commonmark/cmark)
#              glade                    (https://glade.gnome.org/)
#              libchamplain             (https://gitlab.gnome.org/GNOME/libchamplain/)
#              --------------------------------------
#              libpst                   (https://www.five-ten-sg.com/libpst/)
#              libunity                 (https://launchpad.net/libunity/)
#              libytnef                 (https://github.com/Yeraze/ytnef)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

cmake                            \
    -D CMAKE_INSTALL_PREFIX=/usr \
    -D SYSCONF_INSTALL_DIR=/etc  \
    -D ENABLE_INSTALLED_TESTS=ON \
    -D ENABLE_PST_IMPORT=OFF     \
    -D ENABLE_YTNEF=OFF          \
    -D ENABLE_CONTACT_MAPS=OFF   \
    -D ENABLE_MARKDOWN=OFF       \
    -D ENABLE_WEATHER=ON         \
    -G Ninja                     \
    .. || exit 1

ninja || exit 1
# пакет не имеет набора тестов
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Email and calendaring application)
#
# The Evolution package contains an integrated mail, calendar and address book
# suite designed for the GNOME environment
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
