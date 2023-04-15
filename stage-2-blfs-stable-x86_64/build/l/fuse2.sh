#! /bin/bash

PRGNAME="fuse2"
ARCH_NAME="fuse"

### Fuse (Filesystem in Userspace)
# FUSE (File system in userspace, файловая система в пространстве пользователя)
# это механизм, позволяющий обычному пользователю подключать различные объекты
# как специфичные файловые системы в собственном пространстве, например на
# жёстком диске.

# Required:    no
# Recommended: no
# Optional:    no

### Конфигурация ядра
#    CONFIG_FUSE_FS=y|m
#    CONFIG_CUSE=y|m

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"      || exit 1
source "${ROOT}/config_file_processing.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${ARCH_NAME}-2*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${ARCH_NAME}-${VERSION}"*.tar.?z* || exit 1
cd "${ARCH_NAME}-${VERSION}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/usr/sbin"

patch -Np1 --verbose -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-fix-build-with-glibc-2.34.patch" || exit 1

autoreconf -fv || exit 1
./configure                   \
    --prefix=/usr             \
    --bindir=/usr/bin         \
    --sbindir=/usr/sbin       \
    --libdir=/usr/lib         \
    --localstatedir=/var      \
    --enable-lib              \
    --enable-util             \
    --disable-static          \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

(
    cd "${TMP_DIR}" || exit 1
    # /sbin все равно остается, переместим в /usr/
    if [ -d ./sbin ]; then
        mv ./sbin/* ./usr/sbin/
        rm -rf ./sbin
    fi

    rm -rf ./etc/init.d ./dev
)

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Filesystem in Userspace)
#
# FUSE is a simple interface for userspace programs to export a virtual
# filesystem to the Linux kernel. FUSE also aims to provide a secure method for
# non privileged users to create and mount their own filesystem
# implementations.
#
# Home page: https://github.com/libfuse/libfuse
# Download:  https://github.com/libfuse/libfuse/releases/download/${ARCH_NAME}-${VERSION}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
