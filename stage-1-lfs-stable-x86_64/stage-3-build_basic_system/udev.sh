#! /bin/bash

PRGNAME="udev"
ARCH_NAME="systemd"

### Udev (dynamic creation of device nodes)
# Утилиты для динамического создания узлов устройств

ROOT="/"
source "${ROOT}check_environment.sh"      || exit 1
source "${ROOT}config_file_processing.sh" || exit 1

SOURCES="/sources"
VERSION="$(echo "${SOURCES}/${ARCH_NAME}"-*.tar.?z* | rev |  cut -d . -f 3- | \
    cut -d - -f 1 | rev)"
BUILD_DIR="${SOURCES}/build"

mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1
rm -rf "${ARCH_NAME}-${VERSION}"

tar xvf "${SOURCES}/${ARCH_NAME}-${VERSION}".tar.?z* || exit 1
cd "${ARCH_NAME}-${VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# удалим две ненужные группы (render и sgx) из правил udev по умолчанию
sed                                      \
    -e 's/GROUP="render"/GROUP="video"/' \
    -e 's/GROUP="sgx", //'               \
    -i rules.d/50-udev-default.rules.in || exit 1

# удалим одно правило udev, требующее полной установки systemd
sed '/systemd-sysctl/s/^/#/' -i rules.d/99-systemd.rules.in || exit 1

# настроим жестко запрограммированные пути к файлам конфигурации сети для
# автономной установки udev
sed -e '/NETWORK_DIRS/s/systemd/udev/' -i \
    src/libsystemd/sd-network/network-util.h || exit 1

mkdir -p build
cd build || exit 1

# отключим некоторые функции, которые разработчики считают экспериментальными
#    -D mode=release
# отключим доступ для всех пользователей к /dev/kvm (редакция считает это
# опасным)
#    -D dev-kvm-mode=0660
# запретим udev связываться с внутренней общей библиотекой systemd
# (libsystemd-shared) предназначенной для совместного использования многими
# компонентами Systemd
#    -D link-udev-shared=false
# предотвратим создание нескольких файлов правил udev, принадлежащих другим
# компонентам Systemd, которые мы не будем устанавливать
#    -D logind=false
#    -D vconsole=false
meson setup ..                \
    --prefix=/usr             \
    --buildtype=release       \
    -D mode=release           \
    -D dev-kvm-mode=0660      \
    -D link-udev-shared=false \
    -D logind=false           \
    -D vconsole=false || exit 1

# получим список поставляемых хелперов udev
UDEV_HELPERS="$(grep "'name' :" ../src/udev/meson.build | \
    awk '{print $3}' | tr -d ",'" | grep -v 'udevadm')"
export UDEV_HELPERS

# создаем только те компоненты, которые необходимы для udev
# shellcheck disable=SC2046
# shellcheck disable=SC2086
ninja                                                              \
    udevadm                                                        \
    systemd-hwdb                                                   \
    $(ninja -n | grep -Eo '(src/(lib)?udev|rules.d|hwdb.d)/[^ ]*') \
    $(realpath libudev.so --relative-to .)                         \
    ${UDEV_HELPERS} || exit 1

# устанавливаем пакет
#
### директории
install -vm755 -d "${TMP_DIR}/usr"/{bin,include,sbin}
install -vm755 -d \
    {"${TMP_DIR}/usr/lib","${TMP_DIR}/etc"}/udev/{hwdb.d,rules.d,network}
install -vm755 -d "${TMP_DIR}/usr"/{lib,share}/pkgconfig
###

### файлы и ссылки
install -vm755 udevadm          "${TMP_DIR}/usr/bin/"           || exit 1
install -vm755 systemd-hwdb     "${TMP_DIR}/usr/bin/udev-hwdb"  || exit 1
ln      -svfn  ../bin/udevadm   "${TMP_DIR}/usr/sbin/udevd"     || exit 1
cp      -av libudev.so{,*[0-9]} "${TMP_DIR}/usr/lib/"           || exit 1
install -vm644 ../src/libudev/libudev.h \
    "${TMP_DIR}/usr/include/"                                   || exit 1
install -vm644 src/libudev/*.pc "${TMP_DIR}/usr/lib/pkgconfig/" || exit 1
install -vm644 src/udev/*.pc "${TMP_DIR}/usr/share/pkgconfig/"  || exit 1
install -vm644 ../src/udev/udev.conf "${TMP_DIR}/etc/udev/"     || exit 1
install -vm644 rules.d/* ../rules.d/README \
    "${TMP_DIR}/usr/lib/udev/rules.d/"                          || exit 1
# shellcheck disable=SC2046
install -vm644 \
    $(find ../rules.d/*.rules -not -name '*power-switch*') \
        "${TMP_DIR}/usr/lib/udev/rules.d/"                      || exit 1
install -vm644 hwdb.d/* ../hwdb.d/{*.hwdb,README} \
    "${TMP_DIR}/usr/lib/udev/hwdb.d/"                           || exit 1
# shellcheck disable=SC2086
install -vm755 ${UDEV_HELPERS} "${TMP_DIR}/usr/lib/udev/"       || exit 1
install -vm644 ../network/99-default.link \
    "${TMP_DIR}/usr/lib/udev/network/"                          || exit 1
###

# установим некоторые пользовательские правила и файлы поддержки из архива
# udev-lfs, которые будут полезные в среде LFS
UDEV_LFS="udev-lfs"
UDEV_LFS_VERSION="$(echo "${SOURCES}/${UDEV_LFS}"-*.tar.?z* | rev | \
    cut -d . -f 3- | cut -d - -f 1 | rev)"

tar   -xvf "${SOURCES}/${UDEV_LFS}-${UDEV_LFS_VERSION}".tar.?z* || exit 1
mkdir -p "${TMP_DIR}/usr/share/doc/${PRGNAME}-${UDEV_LFS_VERSION}"
make  -f "${UDEV_LFS}-${UDEV_LFS_VERSION}/Makefile.lfs" install \
    DESTDIR="${TMP_DIR}"|| exit 1

# удалим документацию
(
    cd "${TMP_DIR}/usr/share/" || exit 1
    rm -rf doc
)

# установим man-страницы
mkdir -p "${TMP_DIR}/usr/share/man"
tar -xf "${SOURCES}/${ARCH_NAME}-man-pages-${VERSION}".tar.?z* \
    --no-same-owner                                            \
    --strip-components=1                                       \
    -C "${TMP_DIR}/usr/share/man"                              \
    --wildcards                                                \
        '*/udev*'                                              \
        '*/libudev*'                                           \
        '*/systemd.link.5'                                     \
        '*/systemd-'{hwdb,udevd.service}.8 || exit 1

sed 's|systemd/network|udev/network|'                \
    "${TMP_DIR}/usr/share/man/man5/systemd.link.5" > \
        "${TMP_DIR}/usr/share/man/man5/udev.link.5" || exit 1

sed 's/systemd\(\\\?-\)/udev\1/'                     \
    "${TMP_DIR}/usr/share/man/man8/systemd-hwdb.8" > \
        "${TMP_DIR}/usr/share/man/man8/udev-hwdb.8" || exit 1

sed 's|lib.*udevd|sbin/udevd|'                                \
    "${TMP_DIR}/usr/share/man/man8/systemd-udevd.service.8" > \
        "${TMP_DIR}/usr/share/man/man8/udevd.8" || exit 1

rm "${TMP_DIR}"/usr/share/man/man*/systemd*
find "${TMP_DIR}/usr/share/man" ! -type d -exec chmod 644 {} \;

# бэкапим конфиг /etc/udev/udev.conf перед установкой пакета
UDEV_CONF="/etc/udev/udev.conf"
if [ -f "${UDEV_CONF}" ]; then
    mv "${UDEV_CONF}" "${UDEV_CONF}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vR "${TMP_DIR}"/* /

config_file_processing "${UDEV_CONF}"

### Конфигурация Udev
# информация об аппаратных устройствах хранится в каталогах
#    /etc/udev/hwdb.d/
#    /usr/lib/udev/hwdb.d/
# для Udev нужно, чтобы эта информация была собрана в двоичной базе данных
#    /etc/udev/hwdb.bin
# создадим эту исходную базу данных
udev-hwdb update                                || exit 1
cp -v /etc/udev/hwdb.bin "${TMP_DIR}/etc/udev/" || exit 1

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (dynamic creation of device nodes)
#
# The Udev package contains programs for dynamic creation of device nodes and
# provides a dynamic device directory containing only the files for the devices
# which are actually present. It creates or removes device node files usually
# located in the /dev directory. udev is a fork of
# https://github.com/systemd/systemd with the aim of isolating udev from any
# particular flavor of system initialization.
#
# Home page: https://wiki.gentoo.org/wiki/Project:Udev
# Download:  https://github.com/${ARCH_NAME}/${ARCH_NAME}/archive/v${VERSION}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
