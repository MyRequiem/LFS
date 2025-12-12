
#! /bin/bash

PRGNAME="colord"

### Colord (Color Profile System Service)
# Системный сервис (демон) для управления цветом, который упрощает работу с
# цветовыми профилями для точного управления цветом на устройствах ввода/вывода

# Required:    dbus
#              glib
#              lcms2
#              libgudev
#              libgusb
#              polkit
#              sqlite
# Recommended: elogind
#              vala
# Optional:    gnome-desktop
#              colord-gtk           (для сборки примеров)
#              --- man-pages --
#              docbook-xml
#              docbook-xsl-ns
#              libxslt
#              ----------------
#              gtk-doc
#              sane
#              argyllcms            (https://www.argyllcms.com/)
#              bash-completion      (https://github.com/scop/bash-completion/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# должны существовать группа и пользователь colord, который сможет взять на
# себя управление демоном после его запуска
! grep -qE "^colord:" /etc/group  && \
    groupadd -g 71 colord

! grep -qE "^colord:" /etc/passwd && \
    useradd -c "Color Daemon Owner"  \
            -d /var/lib/colord       \
            -g colord                \
            -s /bin/false            \
            -u 71 colord

mkdir build
cd build || exit 1

meson setup ..                \
    --prefix=/usr             \
    --buildtype=release       \
    -D daemon_user=colord     \
    -D vapi=true              \
    -D systemd=false          \
    -D libcolordcompat=true   \
    -D argyllcms_sensor=false \
    -D bash_completion=true   \
    -D docs=false             \
    -D man=false || exit 1

ninja || exit 1
DESTDIR="${TMP_DIR}" ninja install

# тесты проводятся в графической среде после установки пакета в систему
# ninja test

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Color Profile System Service)
#
# Colord is a system service that makes it easy to manage, install, and
# generate color profiles. It is used mainly by GNOME Color Manager for system
# integration and use when no users are logged in
#
# Home page: https://www.freedesktop.org/software/${PRGNAME}/
# Download:  https://www.freedesktop.org/software/${PRGNAME}/releases/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
