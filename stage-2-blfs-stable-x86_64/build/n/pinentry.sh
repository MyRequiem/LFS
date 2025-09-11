#! /bin/bash

PRGNAME="pinentry"

### pinentry (PIN Entry dialogs)
# Набор простых диалоговых утилит для ввода ввода ПИН-кода или парольной фразы,
# которые использует протокол Assuan. Утилиты ввода PIN-кода обычно запускаются
# демоном gpg-agent, но также могут быть запущены и из командной строки.

# Required:    libassuan
#              libgpg-error
# Recommended: no
# Optional:    emacs                         (для сборки 'pinentry-emacs')
#              fltk                          (для сборки 'pinentry-fltk')
#              qt6                           (для сборки 'pinentry-qt')
#              gcr4 или gcr3
#              kde-frameworks
#              libsecret
#              efl                           (https://www.enlightenment.org/about-efl)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# установим совместимость с fltk-1.4.1
sed -i "/FLTK 1/s/3/4/"   configure || exit 1
sed -i '14456 s/1.3/1.4/' configure || exit 1

QT6="--disable-pinentry-qt"
FLTK="--disable-pinentry-fltk"

[ -x /opt/qt6/bin/assistant ] && QT6="--enable-pinentry-qt"
command -v fluid &>/dev/null && FLTK="--enable-pinentry-fltk"

./configure                \
    --prefix=/usr          \
    --enable-pinentry-tty  \
    --disable-pinentry-qt5 \
    "${QT6}"               \
    "${FLTK}" || exit 1

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
