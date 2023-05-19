#! /bin/bash

PRGNAME="translate-shell"

### translate-shell (a command-line translator)
# Translate Shell (ранее Google Translate CLI) - это переводчик командной
# строки. Работает с Google Translate (по умолчанию), Bing Translator,
# Yandex.Translate и Apertium

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим prefix в Makefile:
#    PREFIX= /usr/local -> /usr
#    TARGET= bash       -> ''
sed                                  \
  -e '/^PREFIX/s,\(/usr\)/local,\1,' \
  -e '/^TARGET/s,bash,'"$TARGET"','  \
  -i Makefile || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

find "${TMP_DIR}/usr/share/man" -type f -exec chmod 644 {} \;

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a command-line translator)
#
# Translate Shell (formerly Google Translate CLI) is a command-line translator
# powered by Google Translate (efault), Bing Translator, Yandex.Translate, and
# Apertium.
#
# Home page: https://www.soimort.org/${PRGNAME}/
# Download:  https://github.com/soimort/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
