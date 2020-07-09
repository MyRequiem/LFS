#! /bin/bash

PRGNAME="pax"
ARCH_NAME="${PRGNAME}mirabilis"

### Pax (tar/cpio compatible archiver)
# Стандартный инструмент архивирования POSIX. Поддерживает две наиболее
# распространенные формы стандартных архивных файлов - CPIO и TAR

# http://www.linuxfromscratch.org/blfs/view/stable/general/pax.html

# Home page: http://wiki.bash-hackers.org/howto/pax
# Download:  http://pub.allbsd.org/MirOS/dist/mir/cpio/paxmirabilis-20161104.cpio.gz

# Required: cpio
# Optional: no

ROOT="/root"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find ${SOURCES} -type f \
    -name "${ARCH_NAME}-*.cpio.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

gzip -dck "${SOURCES}/${ARCH_NAME}-${VERSION}.cpio.gz" | cpio -mid || exit 1

mv "${PRGNAME}" "${PRGNAME}-${VERSION}"
cd "${PRGNAME}-${VERSION}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
MAN="/usr/share/man/man1"
mkdir -pv "${TMP_DIR}"{/bin,"${MAN}"}

# устраним некоторые раздражающие предупреждения
sed -i '/stat.h/a #include <sys/sysmacros.h>' cpio.c gen_subs.c tar.c || exit 1

cc -O2 -DLONG_OFF_T -o pax -DPAX_SAFE_PATH=\"/bin\" ./*.c

install -v pax /bin
install -v pax "${TMP_DIR}/bin"
install -vm 644 pax.1 "${MAN}"
install -vm 644 pax.1 "${TMP_DIR}${MAN}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (tar/cpio compatible archiver)
#
# pax is an archiving utility created by POSIX and defined by the POSIX.1-2001
# standard. Rather than sort out the incompatible options that have crept up
# between tar and cpio, along with their implementations across various
# versions of UNIX, the IEEE designed a new archive utility. The name 'pax' is
# an acronym for portable archive exchange. Furthermore, 'pax' means 'peace' in
# Latin, so its name implies that it shall create peace between the tar and
# cpio format supporters. The command invocation and command structure is
# somewhat a unification of both tar and cpio.
#
# Home page: http://wiki.bash-hackers.org/howto/${PRGNAME}
# Download:  http://pub.allbsd.org/MirOS/dist/mir/cpio/${PRGNAME}mirabilis-${VERSION}.cpio.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
