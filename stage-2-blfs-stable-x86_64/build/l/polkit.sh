#! /bin/bash

PRGNAME="polkit"

### Polkit (PolicyKit authentication framework)
# API библиотеки, которые используется для предоставления непривилегированным
# процессам возможности выполнения действий, требующих прав администратора.
# Использование Polkit противопоставляется использованию таких систем, как
# sudo, но не наделяет процесс пользователя правами администратора, а позволяет
# точно контролировать, что разрешено, а что запрещено.

# Required:    glib
#              duktape
#              --- для сборки man-страниц ---
#              libxslt
#              docbook-xml
#              docbook-xsl
# Recommended: linux-pam
#              elogind
# Optional:    gtk-doc
#              mozjs
#              python3-dbusmock (для тестов)
#              Plasma5          (для KDE)
#              gnome-shell      (для GNOME)
#              polkit-gnome     (для XFCE)
#              lxsession        (для LXDE)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# добавим группу polkitd, если не существует
! grep -qE "^polkitd:" /etc/group  && \
    groupadd -fg 27 polkitd

# добавим пользователя polkitd, если не существует
! grep -qE "^polkitd:" /etc/passwd && \
    useradd -c "PolicyKit Daemon Owner" \
            -d /etc/polkit-1 \
            -u 27            \
            -g polkitd       \
            -s /bin/false polkitd

AUTHFW="shadow"
INTROSPECTION="false"
GTK_DOC="false"
TESTS="false"

command -v faillock      &>/dev/null && AUTHFW="pam"
command -v g-ir-compiler &>/dev/null && INTROSPECTION="true"
# command -v gtkdoc-check  &>/dev/null && GTK_DOC="true"

mkdir build
cd build || exit 1

meson                                  \
    --prefix=/usr                      \
    --buildtype=release                \
    -Dman=true                         \
    -Dauthfw="${AUTHFW}"               \
    -Dsession_tracking=libelogind      \
    -Dsystemdsystemunitdir=/tmp        \
    -Dintrospection="${INTROSPECTION}" \
    -Dtests=${TESTS}                   \
    -Djs_engine=duktape                \
    -Dgtk_doc="${GTK_DOC}"             \
    .. || exit 1

ninja || exit 1
# meson test -t3
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/tmp"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (PolicyKit authentication framework)
#
# PolicyKit is an application-level toolkit for defining and handling the
# policy that allows unprivileged processes to speak to privileged processes.
# PolicyKit is specifically targeting applications in rich desktop environments
# on multi-user UNIX-like operating systems.
#
# Home page: http://www.freedesktop.org/wiki/Software/PolicyKit
# Download:  https://gitlab.freedesktop.org/${PRGNAME}/${PRGNAME}/-/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
