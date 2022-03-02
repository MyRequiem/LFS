#! /bin/bash

PRGNAME="vde2"

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
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправляем cryptcab.c с gcc >= 10, иначе при сборки без параметра
# --disable-cryptcab возникает ошибка
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-cryptcab.patch" || exit 1

./configure              \
    --prefix=/usr        \
    --sysconfdir=/etc    \
    --localstatedir=/var \
    --enable-static=no   \
    --enable-shared=yes  \
    --disable-experimental || exit 1

make -j1 || exit 1
# make check
make -j1 install DESTDIR="${TMP_DIR}"

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
# Home page: https://github.com/virtualsquare/vde-2
# Download:  http://downloads.sourceforge.net/project/vde/${PRGNAME}/${VERSION}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
