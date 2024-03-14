#! /bin/bash

PRGNAME="ebtables"

### ebtables (Ethernet frame filtering on a Linux bridge)
# Средство фильтрации пакетов для программных мостов Linux. ebtables похоже на
# iptables, но отличается тем, что работает преимущественно не на третьем
# (сетевом), а на втором (канальном) уровне сетевого стека.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1

SOURCES="${ROOT}/src"
ARCH_VERSION="$(find "${SOURCES}" -type f \
    -name "${PRGNAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1,2 | rev | cut -d v -f 2)"

VERSION="${ARCH_VERSION//-/_}"
BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}-v${ARCH_VERSION}".tar.?z* || exit 1
cd "${PRGNAME}-v${ARCH_VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# избегаем 'все предупреждения являются ошибками', которые прерывают сборку
sed -e "s|-Wunused|-Wno-error=unused-but-set-variable|" -i Makefile || exit 1

make || exit 1
make                      \
    BINDIR=/usr/sbin      \
    MANDIR=/usr/share/man \
    install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/etc"/{rc.d,sysconfig}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MVERSION="${ARCH_VERSION//./-}"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Ethernet frame filtering on a Linux bridge)
#
# The ebtables utility enables basic Ethernet frame filtering on a Linux
# bridge, logging, MAC NAT and brouting. It only provides basic IP filtering,
# the full-fledged IP filtering on a Linux bridge is done with iptables.
#
# Home page: http://${PRGNAME}.netfilter.org/
# Download:  https://nav.dl.sourceforge.net/project/${PRGNAME}/${PRGNAME}/${PRGNAME}-${MVERSION}/${PRGNAME}-v${ARCH_VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
