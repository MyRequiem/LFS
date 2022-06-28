#! /bin/bash

PRGNAME="rpm2tgz"
UTILNAME="rpm2targz"
VERSION="1.2.2"

### rpm2tgz (a tool for converting an RPM archive into a tar+gz one)
# Конвертирует пакеты .rpm в пакеты Slackware (tgz, txz)

# Required:    rpm
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/usr/bin"

SOURCES="${ROOT}/src"
cc -o "${TMP_DIR}/usr/bin/rpmoffset" "${SOURCES}/rpmoffset.c"  || exit 1
cat "${SOURCES}/${UTILNAME}" > "${TMP_DIR}/usr/bin/${PRGNAME}" || exit 1
chmod 755 "${TMP_DIR}/usr/bin"/*

cd "${TMP_DIR}/usr/bin" || exit 1

PATCHES="\
    0001-fix-d-handling.patch.gz                              \
    0002-fix-spurious-path-to-rpm-file-with-n-option.patch.gz \
    0003-allow-every-user-to-use-rpm2tgz.patch.gz             \
    0004-produce-more-compliant-slack-desc.patch.gz           \
"
for PATCH in ${PATCHES}; do
    zcat "${SOURCES}/${PATCH}" | patch --verbose -p1 || exit 1
done

mv "${PRGNAME}" "${UTILNAME}"
PATCHES="\
    0007-Add-support-for-.txz-packages-and-rpm2txz-symlink.patch.gz \
    0008-Avoid-none-values-in-slack-desc.patch.gz                   \
    0009-Add-c-option-just-as-makepkg-c-y.patch.gz                  \
    0011-ignore-rpm2cpio-error-code.patch.gz                        \
"
for PATCH in ${PATCHES}; do
    zcat "${SOURCES}/${PATCH}" | patch --verbose -p1 || exit 1
done

# ссылки в /usr/bin
#    rpm2tgz -> rpm2targz
#    rpm2txz -> rpm2targz
ln -s "${UTILNAME}" "${PRGNAME}"
ln -s "${UTILNAME}" rpm2txz

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a tool for converting an RPM archive into a tar+gz one)
#
# Converts RPM format to Slackware's GNU tar + GNU zip format. Converted
# packages come with no warranty ;-)
#
# Home page: https://mirrors.slackware.com/slackware/slackware64-current/source/a/${PRGNAME}/
# Download:  https://mirrors.slackware.com/slackware/slackware64-current/source/a/${PRGNAME}/${UTILNAME}
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
