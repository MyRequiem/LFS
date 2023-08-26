#! /bin/bash

PRGNAME="polkit"
DOCBOOK_XML_VERSION="4.5"
DOCBOOK_XSL_VERSION="1.79.2"

### Polkit (PolicyKit authentication framework)
# API библиотеки, которые используется для предоставления непривилегированным
# процессам возможности выполнения действий, требующих прав администратора.
# Использование Polkit противопоставляется использованию таких систем, как
# sudo, но не наделяет процесс пользователя правами администратора, а позволяет
# точно контролировать, что разрешено, а что запрещено.

# Required:    glib
#              mozjs
# Recommended: linux-pam
#              elogind
# Optional:    gobject-introspection
#              python3-dbus
#              python3-dbusmock
#              docbook-xml
#              docbook-xsl
#              gtk-doc
#              libxslt
#              polkit-kde-agent
#              gnome-shell
#              polkit-gnome
#              lxsession

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

# исправим ошибку, возникающую при использовании последних версий Polkit вместе
# с elogind
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-fix_elogind_detection-1.patch" || exit 1

# для построения man-страниц требуются опциональные зависимости libxslt,
# docbook-xml и docbook-xsl
MAN_PAGES="--disable-man-pages"
LIBXSLT=""
DOCBOOK_XML=""
DOCBOOK_XSL=""
GTK_DOC="--disable-gtk-doc"
AUTHFW="shadow"
LIBELOGIND="no"
INTROSPECTION="no"

command -v xslt-config &>/dev/null && LIBXSLT="true"
[ -f "/usr/share/xml/docbook/xml-dtd-${DOCBOOK_XML_VERSION}/ent/README" ] && \
    DOCBOOK_XML="true"
[ -f "/usr/share/doc/docbook-xsl-${DOCBOOK_XSL_VERSION}/README" ] && \
    DOCBOOK_XSL="true"
[[ -n "${LIBXSLT}" && -n "${DOCBOOK_XML}" && -n "${DOCBOOK_XSL}" ]] && \
    MAN_PAGES="--enable-man-pages"

# command -v gtkdoc-check    &>/dev/null && GTK_DOC="--enable-gtk-doc"
command -v pam_tally       &>/dev/null && AUTHFW="pam"
command -v elogind-inhibit &>/dev/null && LIBELOGIND="yes"
command -v g-ir-compiler   &>/dev/null && INTROSPECTION="yes"

autoreconf -fv || exit 1
./configure                             \
    --prefix=/usr                       \
    --sysconfdir=/etc                   \
    --localstatedir=/var                \
    --disable-static                    \
    --with-os-type=LFS                  \
    "${MAN_PAGES}"                      \
    "${GTK_DOC}"                        \
    --with-authfw=${AUTHFW}             \
    --disable-libsystemd-login          \
    --enable-libelogind="${LIBELOGIND}" \
    --enable-introspection="${INTROSPECTION}" || exit 1

make || exit 1

### тесты
# для прохождения тестового набора должен быть запущен системный демон D-Bus
# make check

make install DESTDIR="${TMP_DIR}"

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
# Download:  https://www.freedesktop.org/software/${PRGNAME}/releases/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
