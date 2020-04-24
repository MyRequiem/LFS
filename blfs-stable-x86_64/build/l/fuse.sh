#! /bin/bash

PRGNAME="fuse"

### Fuse (Filesystem in Userspace)
# FUSE (File system in userspace, файловая система в пространстве пользователя)
# это механизм, позволяющий обычному пользователю подключать различные объекты
# как специфичные файловые системы в собственном пространстве, например на
# жёстком диске.

# http://www.linuxfromscratch.org/blfs/view/stable/postlfs/fuse.html

# Home page: http://fuse.sourceforge.net
# Download:  https://github.com/libfuse/libfuse/releases/download/fuse-3.9.0/fuse-3.9.0.tar.xz

# Required: no
# Optional: doxygen (для сборки API документации)

### Конфигурация ядра
#    CONFIG_FUSE_FS=y|m

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"{/{bin,etc,lib,sbin},"${DOCS}"}

# отключим установку ненужного загрузочного скрипта и правила udev
sed -i '/^udev/,$ s/^/#/' util/meson.build || exit 1

mkdir build
cd    build || exit 1

meson             \
    --prefix=/usr \
    .. || exit 1

ninja || exit 1

# если пакет doxygen установлен, то собираем документацию
command -v doxygen &>/dev/null && doxygen doc/Doxyfile

# пакет не имеет набора тестов, сразу устанавливаем
ninja install
DESTDIR="${TMP_DIR}" ninja install

# переместим /usr/lib/libfuse3.so.* в /lib и пересоздадим ссылку
# /usr/lib/libfuse3.so
mv -vf /usr/lib/libfuse3.so.* /lib
ln -sfvn "../../lib/$(readlink /usr/lib/libfuse3.so)" /usr/lib/libfuse3.so
(
    cd "${TMP_DIR}/usr/lib" || exit 1
    mv -vf libfuse3.so.* "${TMP_DIR}/lib"
    ln -sfvn "../../lib/$(readlink libfuse3.so)" libfuse3.so
)

mv -vf /usr/bin/fusermount3             /bin
mv -vf "${TMP_DIR}/usr/bin/fusermount3" "${TMP_DIR}/bin"
chmod u+s /bin/fusermount3
chmod u+s "${TMP_DIR}/bin/fusermount3"

mv -vf /usr/sbin/mount.fuse3             /sbin
mv -vf "${TMP_DIR}/usr/sbin/mount.fuse3" "${TMP_DIR}/sbin"

# документация
install -v -m755 -d "${DOCS}"
install -v -m644 ../doc/{README.NFS,kernel.txt} "${DOCS}"
install -v -m644 ../doc/{README.NFS,kernel.txt} "${TMP_DIR}${DOCS}"

cp -Rv ../doc/html "${DOCS}"
cp -Rv ../doc/html "${TMP_DIR}${DOCS}"

### Конфигурация Fuse
# некоторые параметры политики монтирования могут быть установлены в файле
# /etc/fuse.conf
FUSE_CONF="/etc/fuse.conf"
if [ -f "${FUSE_CONF}" ]; then
    mv "${FUSE_CONF}" "${FUSE_CONF}.old"
fi

cat << EOF > "${FUSE_CONF}"
# Begin ${FUSE_CONF}

# The config file ${FUSE_CONF} allows for the following parameters:

### user_allow_other
# using the allow_other mount option works fine as root, in order to have it
# work as user you need user_allow_other in /etc/fuse.conf as well. This option
# allows users to use the allow_other option. You need allow_other if you want
# users other than the owner to access a mounted fuse. This option must appear
# on a line by itself. There is no value, just the presence of the option.

# user_allow_other

### mount_max
# set the maximum number of FUSE mounts allowed to non-root users. The default
# is 1000.

# mount_max = 1000

# End ${FUSE_CONF}
EOF

config_file_processing "${FUSE_CONF}"
cp "${FUSE_CONF}" "${TMP_DIR}/etc"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Filesystem in Userspace)
#
# FUSE is a simple interface for userspace programs to export a virtual
# filesystem to the Linux kernel. FUSE also aims to provide a secure method for
# non privileged users to create and mount their own filesystem
# implementations.
#
# Home page: http://fuse.sourceforge.net
# Download:  https://github.com/libfuse/libfuse/releases/download/${PRGNAME}-${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
