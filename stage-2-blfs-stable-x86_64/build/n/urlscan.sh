#! /bin/bash

PRGNAME="urlscan"

### urlscan (replacement for urlview, a web browser launcher for mutt)
# Утилита для интеграции с mutt mailreader, позволяющая легко запускать в
# веб-браузере URL-адреса, содержащиеся в сообщених электронной почты. Является
# заменой для утилиты urlview

# Required:    python3
#              python-urwid
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

python3 setup.py build || exit 1
python3 setup.py install --optimize=1 --root="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share/doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (replacement for urlview, a web browser launcher for mutt)
#
# Urlscan is a small program that is designed to integrate with the "mutt"
# mailreader to allow you to easily launch a Web browser for URLs contained in
# email messages. It is a replacement for the "urlview" program.
#
# Home page: https://github.com/firecat53/${PRGNAME}
# Download:  https://github.com/firecat53/${PRGNAME}/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
