#! /bin/bash

PRGNAME="polkit"

### Polkit (PolicyKit authentication framework)
# API библиотеки, которые используется для предоставления непривилегированным
# процессам возможности выполнения действий, требующих прав администратора.
# Использование Polkit противопоставляется использованию таких систем, как
# sudo, но не наделяет процесс пользователя правами администратора, а позволяет
# точно контролировать, что разрешено, а что запрещено.

# Required:    glib
# Recommended: duktape
#              --- для сборки man-страниц ---
#              libxslt
#              docbook-xml
#              docbook-xsl
#              linux-pam
#              elogind
# Optional:    gtk-doc
#              python3-dbusmock     (для тестов)
#              Plasma5              (для KDE)
#              gnome-shell          (для GNOME)
#              polkit-gnome         (для XFCE)
#              lxqt-policykit       (для LXQt)

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

# исправим проблему сборки для систем на базе sysV
sed -i '/systemd_sysusers_dir/s/^/#/' meson.build

mkdir build
cd build || exit 1

meson setup ..                    \
      --prefix=/usr               \
      --buildtype=release         \
      -D man=false                \
      -D session_tracking=elogind \
      -D authfw=shadow            \
      -D tests=false

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

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
# Home page: https://www.freedesktop.org/wiki/Software/PolicyKit/
# Download:  https://github.com/${PRGNAME}-org/${PRGNAME}/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
