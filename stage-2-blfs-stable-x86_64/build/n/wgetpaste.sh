#! /bin/bash

PRGNAME="wgetpaste"

### wgetpaste (command-line interface to various pastebins)
# Интерфейс командной строки для загрузки содержимого файлов на различные
# сервисы (bpaste, codepad, paste, gists)

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
ZSH_DIR="/usr/share/zsh/site-functions"
MAN_DIR="/usr/share/man/man1"
mkdir -pv "${TMP_DIR}"{/etc,/usr/bin,"${MAN_DIR}","${ZSH_DIR}"}

# заменяем команду emerge (linux gentoo дистрибутив) на свои
#    emerge x11-misc/xclip -> install xclip
#    emerge --info         -> wgetpaste_info
#    --ignore-default-opts -> ''
sed -i \
    -e 's,emerge --info,wgetpaste_info,g' \
    -e 's,emerge x11-misc/,install ,g' \
    -e 's,x11-misc/,,g' \
    -e '/^INFO_ARGS/s,"[^"]*","",' \
    "${PRGNAME}" || exit 1

install -groot -oroot -m0755 "${PRGNAME}"                 "${TMP_DIR}/usr/bin"
install -groot -oroot -m0755 "${SOURCES}/${PRGNAME}_info" "${TMP_DIR}/usr/bin"
install -groot -oroot -m0644 "_${PRGNAME}"                "${TMP_DIR}${ZSH_DIR}"
install -groot -oroot -m0644 "${SOURCES}/${PRGNAME}.1"    "${TMP_DIR}${MAN_DIR}"
install -groot -oroot -m0644 "${SOURCES}/${PRGNAME}.example" \
    "${TMP_DIR}/etc/${PRGNAME}.conf.sample"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (command-line interface to various pastebins)
#
# wgetpaste is a command line interface for various pastebins
#
# Home page: http://${PRGNAME}.zlin.dk/
# Download:  http://${PRGNAME}.zlin.dk/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
