#! /bin/bash

PRGNAME="mutt"

### Mutt (the Mutt mail user agent)
# Небольшой, но очень мощный текстовый почтовый клиент, обладающий широкими
# возможностями настройки.

# Required:    no
# Recommended: lynx или links или w3m (http://w3m.sourceforge.net/) или elinks (http://elinks.or.cz/)
# Optional:    aspell
#              cyrus-sasl
#              gdb
#              gnupg
#              gnutls
#              gpgme
#              libidn
#              mit-kerberos-v5
#              dovecot или exim или postfix или sendmail
#              slang
#              sqlite
#              libgssapi (http://www.citi.umich.edu/projects/nfsv4/linux/)
#              mixmaster (http://mixmaster.sourceforge.net/)
#              qdbm      (http://fallabs.com/qdbm/) или tokyo-cabinet (http://fallabs.com/tokyocabinet/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# для просмотра текстовой документации заменим elinks на links
sed -i -e 's/ -with_backspaces//' -e 's/elinks/links/' \
    -e 's/-no-numbering -no-references//' doc/Makefile.in || exit 1

./configure                   \
    --prefix=/usr             \
    --sysconfdir=/etc         \
    --with-ssl                \
    --enable-pop              \
    --enable-imap             \
    --with-sasl               \
    --enable-smtp             \
    --enable-gpgme            \
    --enable-hcache           \
    --enable-sidebar          \
    --enable-compressed       \
    --enable-external-dotlock \
    --with-docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

rm -f "${TMP_DIR}/etc/"{Muttrc,mime.types}.dist

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

chgrp -v mail   /var/mail
chown root:mail /usr/bin/mutt_dotlock
chmod -v 2755   /usr/bin/mutt_dotlock

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (the Mutt mail user agent)
#
# Mutt is a small but very powerful text-based MIME mail client. Mutt is highly
# configurable, and is well suited to the mail power user with advanced
# features like key bindings, keyboard macros, mail threading, regular
# expression searches and a powerful pattern matching language for selecting
# groups of messages.
#
# Home page: http://www.${PRGNAME}.org
# Download:  ftp://ftp.${PRGNAME}.org/pub/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
