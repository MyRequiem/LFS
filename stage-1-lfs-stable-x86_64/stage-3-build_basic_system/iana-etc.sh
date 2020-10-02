#! /bin/bash

PRGNAME="iana-etc"

### Iana-Etc (data for network services)
# Пакет Iana-Etc предоставляет данные для сетевых служб и протоколов
#
# /etc/protocols    - описывает различные доступные интернет-протоколы DARPA
#                       из подсистемы TCP/IP
# /etc/services     - обеспечивает соответствие между дружественными текстовыми
#                       именами для Интернет услуг, а также соответствующие им
#                       номера портов и типы протокола

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/etc"

cp services protocols "${TMP_DIR}/etc"

/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (data for network services)
#
# The Iana-Etc package provides data for network services and protocols:
#
#    /etc/protocols - describes the various DARPA Internet protocols that are
#                       available from the TCP/IP subsystem
#    /etc/services  -  provides a mapping between friendly textual names for
#                       internet services, and their underlying assigned port
#                       numbers and protocol types
#
# Home page: http://freecode.com/projects/${PRGNAME}
# Download:  https://github.com/Mic92/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
