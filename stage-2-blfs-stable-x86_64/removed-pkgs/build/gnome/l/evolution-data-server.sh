#! /bin/bash

PRGNAME="evolution-data-server"

### Evolution Data Server (Desktop Information Store)
# Сервер данных в среде рабочего стола GNOME, который централизованно управляет
# информацией о почте, календарях, адресных книгах, задачах и заметках для
# приложений, таких как почтовый клиент Evolution. Выступает как сервер базы
# данных, обрабатывая и предоставляя эти данные другим программам.

# Required:    libical
#              libsecret
#              nss
#              sqlite
# Recommended: gnome-online-accounts
#              glib
#              gtk+3
#              gtk4
#              icu
#              libcanberra
#              libgweather
#              vala
#              webkitgtk
#              blocaled                 (Runtime)
# Optional:    gtk-doc
#              mit-kerberos-v5
#              --- один из (MTA) ---
#              dovecot
#              exim
#              postfix
#              sendmail
#              ---------------------
#              openldap
#              berkeley-db              (https://anduin.linuxfromscratch.org/BLFS/bdb/db-5.3.28.tar.gz)
#              libphonenumber           (https://github.com/googlei18n/libphonenumber/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

cmake                             \
    -D CMAKE_INSTALL_PREFIX=/usr  \
    -D SYSCONF_INSTALL_DIR=/etc   \
    -D ENABLE_VALA_BINDINGS=ON    \
    -D ENABLE_INSTALLED_TESTS=ON  \
    -D WITH_OPENLDAP=OFF          \
    -D WITH_KRB5=OFF              \
    -D ENABLE_INTROSPECTION=ON    \
    -D ENABLE_GTK_DOC=OFF         \
    -D WITH_LIBDB=OFF             \
    -D WITH_SYSTEMDUSERUNITDIR=no \
    -W no-dev                     \
    -G Ninja                      \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Desktop Information Store)
#
# The Evolution Data Server package provides a unified backend for programs
# that work with contacts, tasks, and calendar information. It was originally
# developed for Evolution (hence the name), but is now used by other packages
# as well
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
