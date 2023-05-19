#! /bin/bash

PRGNAME="grc"
### grc (generic colouriser)
# утилита командной строки позволяющая улучшить читабельности текстовых файлов
# или результатов работы различных программ путем вставки в них кодов
# управления цветом, например, ping, tracerout, netstat, make, mount и т.д.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
ETC_DEFAULT="/etc/default"
mkdir -pv "${TMP_DIR}${ETC_DEFAULT}"

# ./install.sh
#    PREFIX=$1
#    ETCPREFIX=$2
./install.sh "${TMP_DIR}/usr" "${TMP_DIR}"

rm -f "${TMP_DIR}/etc/${PRGNAME}".{fish,zsh}

cat << EOF > "${TMP_DIR}${ETC_DEFAULT}/${PRGNAME}"
GRC_ALIASES=true
EOF

GRC_CONF="/etc/${PRGNAME}.conf"
if [ -f "${GRC_CONF}" ]; then
    mv "${GRC_CONF}" "${GRC_CONF}.old"
fi

GRC_SH="/etc/profile.d/${PRGNAME}.sh"
chmod 755 "${TMP_DIR}${GRC_SH}"
if [ -f "${GRC_SH}" ]; then
    mv "${GRC_SH}" "${GRC_SH}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${GRC_CONF}"
config_file_processing "${GRC_SH}"

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (generic colouriser)
#
# grc provides two programs: grc and grcat. The main is grcat, which acts as a
# filter, i.e. taking standard input, colourising it and writing to standard
# output. grcat takes as a parameter the name of configuration file.
#
# Home page: https://github.com/garabik/${PRGNAME}
# Download:  https://github.com/garabik/${PRGNAME}/archive/v${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
