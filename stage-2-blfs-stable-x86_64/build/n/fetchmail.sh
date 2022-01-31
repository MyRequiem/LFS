#! /bin/bash

PRGNAME="fetchmail"

### Fetchmail (mail retrieval and forwarding utility)
# Утилита извлекает почту с удаленных почтовых серверов и доставляет ее на
# локальную (клиентскую) машину.

# Required:    no
# Recommended: procmail
# Optional:    mit-kerberos-v5
#              python3         (собранный после TK и python2-future - https://python-future.org/)
#              libgssapi       (http://www.citi.umich.edu/projects/nfsv4/linux/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# создадим пользователя fetchmail
! grep -qE "^fetchmail:" /etc/passwd && \
    useradd                 \
        -c "Fetchmail User" \
        -d /dev/null        \
        -g nogroup          \
        -s /bin/false       \
        -u 38 fetchmail

PYTHON=python3    \
./configure       \
    --prefix=/usr || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

chown -v fetchmail:nogroup "/usr/bin/${PRGNAME}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (mail retrieval and forwarding utility)
#
# fetchmail is a mail retrieval and forwarding utility. It fetches mail from a
# POP, IMAP, or ETRN-capable remote mailserver and forwards it to your local
# (client) machine's delivery system. You can then handle the retrieved mail
# using normal mail user agents such as elm, pine, or mutt. The fetchmail
# utility can be run in a daemon mode to repeatedly poll one or more systems at
# a specified interval. fetchmail is probably not secure.
#
# Home page: https://www.${PRGNAME}.info/
# Download:  https://downloads.sourceforge.net/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
