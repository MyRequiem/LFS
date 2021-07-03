#! /bin/bash

PRGNAME="pinentry"

### pinentry (PIN Entry dialogs)
# Набор простых диалоговых утилит для ввода ввода ПИН-кода или парольной фразы,
# которые использует протокол Assuan. Утилиты ввода PIN-кода обычно запускаются
# демоном gpg-agent, но также могут быть запущены и из командной строки.

# Required: libassuan
#           libgpg-error
# Optional: emacs     (для сборки 'pinentry-emacs')
#           fltk      (для сборки 'pinentry-fltk')
#           gcr
#           gtk+2
#           gtk+3
#           libsecret
#           qt5       (для сборки 'pinentry-qt')
#           efl       (https://www.enlightenment.org/about-efl)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

FLTK="--disable-pinentry-fltk"
GTK2="--disable-pinentry-gtk2"
GTK3="--disable-pinentry-gnome3"
LIBSECRET="--disable-libsecret"
QT="--disable-pinentry-qt"
EMACS_PIN="--disable-pinentry-emacs"
EMACS_HACK="--disable-inside-emacs"

command -v fltk-config &>/dev/null && FLTK="--enable-pinentry-fltk"
command -v gtk-demo    &>/dev/null && GTK2="--enable-pinentry-gtk2"
command -v gtk3-demo   &>/dev/null && GTK3="--enable-pinentry-gnome3"
command -v secret-tool &>/dev/null && LIBSECRET="--enable-libsecret"
command -v assistant   &>/dev/null && QT="--enable-pinentry-qt"
command -v emacs       &>/dev/null && EMACS_PIN="--enable-pinentry-emacs" && \
    EMACS_HACK="--enable-inside-emacs"

./configure         \
    --prefix=/usr   \
    "${FLTK}"       \
    "${GTK2}"       \
    "${GTK3}"       \
    "${LIBSECRET}"  \
    "${QT}"         \
    "${EMACS_PIN}"  \
    "${EMACS_HACK}" \
    --enable-pinentry-tty || exit 1

make || exit 1
# пакет не содержит набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (PIN Entry dialogs)
#
# The PIN-Entry package contains a collection of simple PIN or pass-phrase
# entry dialogs which utilize the Assuan protocol as described by the Дgypten
# project. PIN-Entry programs are usually invoked by the gpg-agent daemon, but
# can be run from the command line as well. There are programs for various
# text-based and GUI environments, including interfaces designed for Ncurses
# (text-based), and for the common GTK and Qt toolkits.
#
# Home page: https://gnupg.org/related_software/${PRGNAME}/index.html
# Download:  https://www.gnupg.org/ftp/gcrypt/${PRGNAME}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
