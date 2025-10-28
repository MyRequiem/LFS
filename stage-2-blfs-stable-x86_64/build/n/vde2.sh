#! /bin/bash

PRGNAME="vde2"
ARCH_NAME="vde"

### vde2 (Virtual Distributed Ethernet)
# Виртуальная сеть, совместимая с Ethernet, которая включает в себя такие
# инструменты, как 'vde_switch' и 'vdeqemu'. Коммутатор VDE имеет несколько
# виртуальных портов, к которым могут быть подключены виртуальные машины,
# приложения, виртуальные интерфейсы и другие инструменты. VDE qemu работает
# как оболочка для запуска qemu/kvm виртуальных машин, которые прозрачно
# подключаются к указанному vde_switch

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${ARCH_NAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${ARCH_NAME}-${VERSION}"*.tar.?z* || exit 1
cd "${ARCH_NAME}-2-${VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

autoreconf -vif || exit 1

export CFLAGS="-std=gnu17"
export SLKCFLAGS="-std=gnu17"
./configure              \
    --prefix=/usr        \
    --sysconfdir=/etc    \
    --localstatedir=/var \
    --enable-static=no   \
    --disable-experimental || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Virtual Distributed Ethernet)
#
# VDE is an ethernet compliant virtual network which includes tools such as
# 'vde_switch' and 'vdeqemu'. VDE switch has several virtual ports where
# virtual machines, applications, virtual interfaces and connectivity tools can
# be virtually plugged in. VDE qemu works as a wrapper for running qemu/kvm
# virtual machines that connects transparently to a specified vde_switch
#
# Home page: https://github.com/virtualsquare/${ARCH_NAME}-2
# Download:  https://github.com/virtualsquare/${ARCH_NAME}-2/archive/v${VERSION}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
